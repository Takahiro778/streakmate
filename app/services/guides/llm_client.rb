# frozen_string_literal: true
require "json"

module Guides
  class LlmClient
    def self.build
      provider = ENV["LLM_PROVIDER"].to_s.presence || (ENV["OPENAI_API_KEY"].present? ? "openai" : nil)
      return nil if provider.blank?
      new(provider: provider)
    end

    def initialize(provider:) = @provider = provider

    def available?
      case @provider
      when "openai" then ENV["OPENAI_API_KEY"].present?
      else false
      end
    end

    # => Array<Hash(title:, body:, icon:, tone:)>
    def suggest(category:, time_band:)
      case @provider
      when "openai" then suggest_openai(category:, time_band:)
      else
        raise "Unsupported provider: #{@provider}"
      end
    end

    private

    def suggest_openai(category:, time_band:)
      require "openai"

      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      model  = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

      resp = client.chat(parameters: {
        model: model,
        temperature: 0.6,
        max_tokens: 500,
        messages: [
          { role: "system", content: "あなたは日本語向けのウェルビーイングコーチです。安全・即実行・自然な日本語（助詞を省略しない）で返します。" },
          { role: "user",   content: build_prompt(category:, time_band:) }
        ]
      })

      content = resp.dig("choices", 0, "message", "content").to_s
      parsed  = JSON.parse(content) rescue nil
      raise "invalid_json_from_llm" unless parsed.is_a?(Array) && parsed.any?

      # ---- 正規化（出来るだけ切らない／自然な整形） ----
      # 目安：title 6-18字, body 50-90字（長すぎる時だけ … で省略）
      title_max = 18
      body_max  = 90

      items = parsed.first(3).map do |h|
        raw_title = tidy(h["title"])
        raw_body  = tidy(h["body"])
        {
          title: trunc_jp(presence_or(raw_title,  "リラックス"), title_max),
          body:  ensure_period(trunc_jp(presence_or(raw_body, "深呼吸をゆっくり3回。今の緊張をほぐしましょう。"), body_max)),
          icon:  emoji_or_default(h["icon"], "💡"),
          tone:  tidy(presence_or(h["tone"], category.to_s == "sleep" ? "静か・穏やか" : "やさしい・ライト"))
        }
      end

      raise "insufficient_items_from_llm" if items.size < 3
      items
    end

    # ---- プロンプト：長さ・文体・改行禁止を明示 ----
    def build_prompt(category:, time_band:)
      tone  = (category.to_s == "sleep") ? "静かで落ち着いた口調" : "やさしく前向きな口調"
      band_hint =
        case time_band
        when :morning    then "朝のリフレッシュ"
        when :afternoon  then "午後の集中維持"
        when :evening    then "夕方の切替と休息"
        when :late_night then "就寝前の穏やかな準備"
        else "今の時間帯に合う"
        end

      <<~P
      次の条件で、日本語の提案カードをちょうど3件返してください。出力は**JSON配列のみ**（余計な文やコードフェンス禁止）。

      前提:
      - category: #{category}  # relax | sleep
      - time_band: #{time_band}  # morning | afternoon | evening | late_night
      - ねらい: #{band_hint}

      厳守事項:
      - 5分以内 / 道具不要 / その場でできる行動
      - title は 6〜18文字程度、body は 50〜90文字程度（読みやすい一文）
      - 改行は入れない（1行に収める）、助詞を省略しない自然な日本語
      - 命令形を避け、提案としてやわらかく（〜してみましょう）
      - 医療行為の示唆や断定は不可（一般的で安全）
      - 形式は必ず JSON 配列（3要素）。各要素は { "title": "", "body": "", "icon": "🎯", "tone": "#{tone}" }

      例（形式のみ。内容は生成し直すこと）:
      [
        {"title":"深呼吸でリラックス","body":"鼻から5秒吸い、口から5秒吐くを3回。肩を下ろし、今の緊張をやさしくほどきます。","icon":"🌬️","tone":"#{tone}"},
        {"title":"首と肩をゆるめる","body":"両肩をゆっくり前後に5回ずつ回す。血流を促し、画面疲れのこわばりを軽くします。","icon":"🧘","tone":"#{tone}"},
        {"title":"白湯を一口飲む","body":"常温の水か白湯を一杯。身体を内側から潤し、気分の切り替えを助けます。","icon":"🥛","tone":"#{tone}"}
      ]
      P
    end

    # ---- 整形ユーティリティ ----
    def tidy(v)
      v.to_s.gsub(/\s+/, " ").strip
    end

    # 末尾に句点がなければ「。」を付ける（！や？はそのまま）
    def ensure_period(s)
      s = s.to_s.strip
      return s if s.empty? || s.end_with?("。", "！", "？", "…")
      "#{s}。"
    end

    # 日本語をなるべく切らず、超過時のみ「…」を付けて省略（絵文字・結合文字対応）
    def trunc_jp(s, max)
      g = s.to_s.scan(/\X/)   # grapheme cluster
      return s if g.length <= max
      (g[0, max - 1].join + "…")
    end

    def presence_or(v, fallback)
      s = v.to_s.strip
      s.empty? ? fallback : s
    end

    def emoji_or_default(v, fallback)
      s = v.to_s.strip
      (s.length <= 3 && !s.empty?) ? s : fallback
    end
  end
end
