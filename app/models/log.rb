class Log < ApplicationRecord
  belongs_to :user

  # --- 任意：ゴール連携（ある場合だけ使われます） ---
  # 先にマイグレーションで logs に goal_id / goal_task_id を追加してください
  belongs_to :goal, optional: true
  belongs_to :goal_task, optional: true

  # === Cheer（応援）関連 ===
  has_many :cheers, dependent: :destroy
  has_many :cheerers, through: :cheers, source: :user

  # === Comment（コメント）関連 ===
  has_many :comments, dependent: :destroy

  # --- カテゴリ / 公開範囲 ---
  enum category: {
    study: 0,
    work: 1,
    exercise: 2,
    rest: 3
  }, _prefix: true
  # => log.category_study?, ...

  enum visibility: {
    public: 0,
    followers: 1,
    private: 2
  }, _prefix: true
  # => log.visibility_public?, ...

  VALID_MINUTES = [15, 30, 45, 60].freeze

  # --- バリデーション ---
  validates :user,    presence: true
  validates :minutes, presence: true,
                      numericality: { only_integer: true },
                      inclusion: { in: VALID_MINUTES }
  validates :category, :visibility, presence: true

  # --- ゴール/タスク連携の軽い整合性チェック（任意） ---
  validate :goal_task_belongs_to_goal, if: -> { goal.present? && goal_task.present? }

  def goal_task_belongs_to_goal
    errors.add(:goal_task, "must belong to the same goal") if goal_task.goal_id != goal_id
  end

  # ログが user に応援されているか（ビュー側の分岐で使用）
  def cheered_by?(user)
    return false if user.blank?
    cheers.exists?(user_id: user.id)
  end

  # --- 共通判定: 可視性チェック（Pundit/ビュー両用） ---
  def visible_to?(viewer)
    case visibility.to_s
    when "public"     then true
    when "private"    then viewer.present? && user_id == viewer.id
    when "followers"  then viewer.present? && (user_id == viewer.id || viewer.follows?(user))
    else false
    end
  end

  # 所有者かどうか（Policy からの利用を想定）
  def owned_by?(viewer)
    viewer.present? && user_id == viewer.id
  end

  # （任意）このログに user がコメント可能かの簡易判定
  # → 可視であればコメント可、に寄せる（必要なら別ポリシーで厳格化）
  def commentable_by?(user)
    return false if user.blank?
    visible_to?(user)
  end

  # --- 範囲/並びスコープ ---
  scope :recent, -> { order(created_at: :desc) }

  scope :between, ->(from_time, to_time) {
    where(created_at: (from_time..to_time))
  }

  scope :on_day, ->(date) {
    where(created_at: date.in_time_zone.all_day)
  }

  scope :this_week, -> {
    where(created_at: Time.zone.now.all_week)
  }

  scope :in_month, ->(date) {
    range = date.in_time_zone.beginning_of_month..date.in_time_zone.end_of_month
    where(created_at: range)
  }

  scope :this_month, -> {
    now = Time.zone.now
    where(created_at: now.beginning_of_month..now.end_of_month)
  }

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

  # Pundit::Scope から呼び出しやすい別名（中身は visible_to）
  def self.policy_scope_for(viewer)
    visible_to(viewer)
  end

  # --- ダッシュボード/円グラフ向けの簡易集計ヘルパ ---
  # 例： Log.visible_to(current_user).this_month.minutes_by_category
  def self.minutes_by_category
    group(:category).sum(:minutes)
  end

  # 例： Log.where(user: current_user).in_month(Date.current).total_minutes
  def self.total_minutes
    sum(:minutes)
  end
end
