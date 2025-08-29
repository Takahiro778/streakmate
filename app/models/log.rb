class Log < ApplicationRecord
  belongs_to :user

  # === Cheer（応援）関連 ===
  has_many :cheers, dependent: :destroy
  has_many :cheerers, through: :cheers, source: :user

  # === Comment（コメント）関連 ===
  has_many :comments, dependent: :destroy

  # ログが user に応援されているか（ビュー側の分岐で使用）
  def cheered_by?(user)
    return false if user.blank?
    cheers.exists?(user_id: user.id)
  end

  # （任意）このログに user がコメント可能かの簡易判定
  def commentable_by?(user)
    return false if user.blank?
    # 可視性はコントローラで visible_to を通す想定だが、念のため自分のログ/公開/フォロワー条件を確認
    return true if user_id == user.id || visibility_public?
    return user.following_ids.include?(user_id) if visibility_followers?
    false
  end

  # カテゴリ（study? が他と衝突しないよう prefix）
  enum category: {
    study: 0,
    work: 1,
    exercise: 2,
    rest: 3
  }, _prefix: true
  # => log.category_study?, log.category_work? ...

  # 公開範囲（public が予約語のため prefix）
  enum visibility: {
    public: 0,
    followers: 1,
    private: 2
  }, _prefix: true
  # => log.visibility_public?, log.visibility_followers?, log.visibility_private?

  VALID_MINUTES = [15, 30, 45, 60].freeze

  validates :minutes, presence: true,
                      numericality: { only_integer: true },
                      inclusion: { in: VALID_MINUTES }
  validates :category, presence: true
  validates :visibility, presence: true
  # memo は任意

  # 日付・週の範囲で抽出
  scope :on_day, ->(date) { where(created_at: date.in_time_zone.all_day) }
  scope :this_week, -> { where(created_at: Time.zone.now.all_week) }

  # タイムライン用
  scope :recent, -> { order(created_at: :desc) }

  # viewer に応じた可視ログ（全体タブ）
  scope :visible_to, ->(viewer) do
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
  end

  # フォロー中タブ（フォロー相手の public/followers）
  scope :timeline_for_following, ->(viewer) do
    ids = Array(viewer&.following_ids)
    if ids.empty?
      none
    else
      where(user_id: ids, visibility: [visibilities[:public], visibilities[:followers]])
    end
  end
end
