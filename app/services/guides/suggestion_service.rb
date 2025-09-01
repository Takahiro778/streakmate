# frozen_string_literal: true
module Guides
  class SuggestionService
    # Public: 表示用のシンプルなDTO
    Suggestion = Struct.new(:title, :body, :icon, :tone, keyword_init: true)

    # now: 時刻依存テスト用に注入可
    # llm: LLM クライアント（nil / unavailable の場合は静的ルールにフォールバック）
    def initialize(now: Time.zone.now, llm: Guides::LlmClient.build)
      @now = now
      @llm = llm
    end

    # category: "relax" | "sleep"
    def suggest(category:)
      # まずは LLM が使えれば LLM を試す（失敗しても静的ルールに即フォールバック）
      if @llm&.available?
        begin
          payload = @llm.suggest(category: category.to_s, time_band: time_band)
          return payload.first(3).map { |h| Suggestion.new(**h.symbolize_keys) }
        rescue => e
          Rails.logger.warn("[LLM fallback] #{e.class}: #{e.message}")
        end
      end

      # ここに来たら静的ルールで返す
      rules_suggest(category: category)
    end

    private

    # --- ここから静的ルール実装（従来の処理をメソッド化） ---

    def rules_suggest(category:)
      rules = RULES.fetch(category.to_s, RULES["relax"])
      band  = time_band
      picks = rules.fetch(band) { rules[:any] }

      # 3件に整形（不足なら any で補完）
      list = picks.dup
      list += rules[:any] if list.size < 3
      list = list.first(3)
      list.map { |h| Suggestion.new(**h) }
    end

    # 時間帯のバンド分け（従来通り）
    def time_band
      h = @now.hour
      return :late_night if h >= 23 || h < 5
      return :morning    if h < 11
      return :afternoon  if h < 17
      :evening
    end

    # 既存の静的ルール（そのまま）
    RULES = {
      "relax" => {
        morning: [
          { title: "首肩ゆるめる1分", body: "深呼吸×3→首を左右各10秒。画面前の凝りを軽減。", icon: "🧘", tone: "ライト" },
          { title: "白湯か常温水",    body: "コップ1杯で脱水予防と代謝ON。",                   icon: "🥛", tone: "ソフト" }
        ],
        afternoon: [
          { title: "目の休憩20-20-20", body: "20分ごとに20秒だけ20フィート先を見る。", icon: "👀", tone: "集中回復" },
          { title: "座り直し30秒",     body: "骨盤を立て直し、肩を後ろへ。",               icon: "🪑", tone: "快適姿勢" }
        ],
        evening: [
          { title: "散歩5分",        body: "家の周りでOK。リズム運動で気分リセット。", icon: "🚶", tone: "軽運動" },
          { title: "温かいお茶",     body: "カフェイン控えめ麦茶/ルイボスで一息。",     icon: "🍵", tone: "ノンカフェイン" }
        ],
        late_night: [
          { title: "照明を落とす", body: "画面輝度も下げて交感神経のブレーキに。", icon: "💡", tone: "就寝準備" },
          { title: "呼吸4-7-8",    body: "4秒吸う→7秒止める→8秒吐く×4セット。",    icon: "🌬️", tone: "自律神経" }
        ],
        any: [
          { title: "ストレッチ30秒", body: "肩回し前後×5。浅い疲労を流す。", icon: "🌀", tone: "汎用" }
        ]
      },
      "sleep" => {
        evening: [
          { title: "入浴/シャワー", body: "就寝90分前の入浴が理想。難しければ首筋を温める。", icon: "🛁", tone: "睡眠準備" },
          { title: "カフェイン終了", body: "この時間以降はノンカフェインに。",               icon: "🚫☕", tone: "刺激カット" }
        ],
        late_night: [
          { title: "画面は温色へ", body: "ブルーライトを抑えてメラトニン妨害を減らす。", icon: "📱", tone: "ディスプレイ" },
          { title: "3分リラックス", body: "横隔膜呼吸：鼻4→止2→口6×6セット。",        icon: "🛌", tone: "副交感" }
        ],
        morning: [
          { title: "起床時は朝光", body: "カーテンを開け、体内時計をリセット。", icon: "🌤️", tone: "概日リズム" }
        ],
        afternoon: [
          { title: "昼寝は20分以内", body: "長い昼寝は夜の睡眠を崩しやすい。", icon: "😴", tone: "パワーナップ" }
        ],
        any: [
          { title: "部屋を涼しく静かに", body: "温度・騒音・光を先に整えるのが近道。", icon: "🎛️", tone: "環境調整" }
        ]
      }
    }.freeze
  end
end
