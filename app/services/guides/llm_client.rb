# frozen_string_literal: true
require "json"

module Guides
  class LlmClient
    def self.build
      provider = ENV["LLM_PROVIDER"].to_s
      return nil if provider.blank?

      new(provider: provider)
    end

    def initialize(provider:)
      @provider = provider
    end

    def available?
      case @provider
      when "openai"
        ENV["OPENAI_API_KEY"].present?
      else
        false
      end
    end

    # 戻り値: Array<Hash> (3件想定) - {title:, body:, icon:, tone:}
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
        temperature: 0.7,
        messages: [
          { role: "system", content: "You are a concise wellbeing coach for Japanese users." },
          { role: "user",   content: prompt }
        ]
      })

      content = resp.dig("choices", 0, "message", "content").to_s
      array   = JSON.parse(content) rescue []

      # 正規化 & ガード
      array.first(3).map do |h|
        {
          title: safe(h["title"], fallback: "Suggestion"),
          body:  safe(h["body"],  fallback: "深呼吸×3。短い休憩を入れましょう。"),
          icon:  safe(h["icon"],  fallback: "💡"),
          tone:  safe(h["tone"],  fallback: "neutral")
        }
      end
    end

    def build_prompt(category:, time_band:)
      <<~PROMPT
      次の条件で、日本語で簡潔な提案カードを3件だけ作成してください。
      出力は **JSON配列のみ** にしてください（余計な文章やコードフェンスは不可）。

      制約:
      - keys: title, body, icon, tone
      - language: Japanese
      - category: #{category}   # relax | sleep
      - time_band: #{time_band} # morning | afternoon | evening | late_night
      - 内容は短く即実行可能（30〜80字程度）
      - 医学的断定や危険行為は不可・一般的で安全なアドバイス
      - icon は1つの絵文字

      例:
      [
        {"title":"首肩ゆるめる1分","body":"深呼吸×3→首を左右各10秒。画面前のこりを軽減。","icon":"🧘","tone":"ライト"},
        {"title":"白湯か常温水","body":"コップ1杯で脱水を防ぎ、気分を落ち着かせる。","icon":"🥛","tone":"ソフト"},
        {"title":"目の休憩20-20-20","body":"20分ごとに20秒だけ遠くを見る。目の緊張をほぐす。","icon":"👀","tone":"集中回復"}
      ]
      PROMPT
    end

    def safe(v, fallback:)
      s = v.to_s.strip
      s.empty? ? fallback : s
    end
  end
end
