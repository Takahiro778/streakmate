class Log < ApplicationRecord
  belongs_to :user

  # 将来の分析のため category は enum（必要に応じて増減OK）
  enum category: {
    study: 0,
    work: 1,
    exercise: 2,
    rest: 3
  }

  # 公開範囲（デフォルト: public）
  enum visibility: {
    public: 0,
    followers: 1,
    private: 2
  }

  # minutes は数値、15/30/45/60のクイックボタン前提（必要なら許容値を拡張）
  VALID_MINUTES = [15, 30, 45, 60].freeze

  validates :minutes, presence: true,
                      numericality: { only_integer: true },
                      inclusion: { in: VALID_MINUTES }
  validates :category, presence: true
  validates :visibility, presence: true
  # memo は任意

  # ✅ スコープ追加
  scope :on_day, ->(date) { where(created_at: date.in_time_zone.all_day) }
  scope :this_week, -> { where(created_at: Time.zone.now.all_week) }

  # ✅ タイムライン表示用
  scope :recent, -> { order(created_at: :desc) }

  # viewer に応じて見えるログ（全体タブ）
  scope :visible_to, ->(viewer) {
    if viewer.nil?
      where(visibility: visibilities[:public])
    else
      where(
        arel_table[:visibility].eq(visibilities[:public])
        .or(arel_table[:user_id].eq(viewer.id)) # 自分のログは常に見える
        .or(
          arel_table[:visibility].eq(visibilities[:followers])
          .and(arel_table[:user_id].in(viewer.following_ids))
        )
      )
    end
  }

  # フォロー中タブ用（フォロー相手の public/followers のみ）
  scope :timeline_for_following, ->(viewer) {
    ids = Array(viewer&.following_ids)
    if ids.empty?
      none
    else
      where(user_id: ids, visibility: [visibilities[:public], visibilities[:followers]])
    end
  }
end
