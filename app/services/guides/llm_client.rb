# frozen_string_literal: true
require "json"

module Guides
  class LlmClient
    # 環境変数未設定でも OPENAI_API_KEY があれば openai を既定に
    def self.build
      provider = ENV["LLM_PROVIDER"].to_s.presence || (ENV["OPENAI_API_KEY"].present? ? "openai" : nil)
      return nil if provider.blank?
      new(provider: provider)
    end

    def initialize(provider:)
      @provider = provider
    end

    def available?
      case @provider
      when "openai" then ENV["OPENAI_API_KEY"].present?
      else false
      end
    end

    # 戻り: Array<Hash(title:, body:, icon:, tone:)> ちょうど3件
    # 失敗時は例外を投げて呼び出し元（SuggestionService）のフォールバックを誘発
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

      prompt = build_prompt(category:, time_band:)

      resp = client.chat(parameters: {
        model: model,
        temperature: 0.6,                 # ぶれ過ぎ防止
        max_tokens: 400,
        messages: [
          { role: "system", content: "あなたは日本語話者向けの短く実行可能なウェルビーイングコーチです。安全・非医療・即実行重視で返答します。" },
          { role: "user",   content: prompt }
        ]
      })

      content = resp.dig("choices", 0, "message", "content").to_s

      # --- 厳格なJSONチェック: 配列3件でない場合は例外にしてフォールバック ---
      parsed = JSON.parse(content) rescue nil
      unless parsed.is_a?(Array) && parsed.any?
        raise "invalid_json_from_llm"
      end

      # 正規化 + ガード（不足キーは補完、文量を短めに丸める）
      items = parsed.first(3).map do |h|
        {
          title: clip(safe(h["title"], "提案"), 24),
          body:  clip(safe(h["body"],  "深呼吸×3で気分を整えましょう。"), 80),
          icon:  emoji_or_default(h["icon"], "💡"),
          tone:  clip(safe(h["tone"],  tone_for(category)), 12)
        }
      end

      # 3件未満なら簡易補完（ここで空なら例外）
      if items.size < 3
        raise "insufficient_items_from_llm"
      end

      items
    end

    # —— プロンプト強化版（カテゴリ/時間帯で制約とトーンを切替） ——
    def build_prompt(category:, time_band:)
      tone  = tone_for(category)
      speed = (category.to_s == "sleep") ? "心を落ち着かせる静かな口調" : "やわらかく前向きな口調"
      time_hint =
        case time_band
        when :morning    then "朝のリフレッシュ"
        when :afternoon  then "午後の集中維持"
        when :evening    then "夕方の切替と休息"
        when :late_night then "就寝前の穏やかな準備"
        else "今の時間帯に合う"
        end

      <<~PROMPT
      次の条件で、日本語の提案カードを「JSON配列のみ」で3件返してください。余計な文章・説明文・コードフェンスは一切禁止。

      コンテキスト:
      - category: #{category}  # relax | sleep
      - time_band: #{time_band}  # morning | afternoon | evening | late_night
      - ねらい: #{time_hint}

      制約:
      - 5分以内/道具不要/その場でできる行動
      - 医療行為の示唆や断定的表現は禁止（一般的で安全）
      - 1件あたり { "title": 短い見出し, "body": 1文の説明, "icon": 1つの絵文字, "tone": "#{tone}" }
      - 全体は必ず JSON 配列（3要素）。例以外の出力禁止。

      スタイル:
      - #{speed}
      - 読点は少なめ、指示はやさしく
      - 数字や手順は簡潔（30〜80字目安）

      例（これは出力するな・形式だけ参照）:
      [
        {"title":"首肩ゆるめる1分","body":"深呼吸×3→首を左右各10秒。画面疲れを和らげる。","icon":"🧘","tone":"#{tone}"},
        {"title":"白湯を一口","body":"常温の水か白湯をゆっくり飲んでリセット。","icon":"🥛","tone":"#{tone}"},
        {"title":"20-20-20","body":"20分ごとに20秒だけ遠くを見る。目の緊張をゆるめる。","icon":"👀","tone":"#{tone}"}
      ]
      PROMPT
    end

    # —— ユーティリティ ——
    def safe(v, fallback)
      s = v.to_s.strip
      s.empty? ? fallback : s
    end

    def emoji_or_default(v, fallback)
      s = v.to_s.strip
      # ざっくり: 1〜3バイトの単一グリフを想定、長い文字列ならデフォルト
      (s.length <= 3 && s != "") ? s : fallback
    end

    def clip(s, max)
      s.to_s.mb_chars.limit(max).to_s
    end

    def tone_for(category)
      category.to_s == "sleep" ? "静か・穏やか" : "やさしい・ライト"
    end
  end
end
