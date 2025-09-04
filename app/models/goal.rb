class Goal < ApplicationRecord
  belongs_to :user

  # 公開範囲（衝突回避のため _prefix を付与）
  enum visibility: { public: 0, followers: 1, private: 2 }, _prefix: :visibility
  # 例: visibility_public?, visibility_followers?, visibility_private?

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category

  # === Favorite（ブックマーク）===
  has_many :favorites,  dependent: :destroy
  has_many :favoriters, through: :favorites, source: :user

  # === GoalTask（ゴール配下の未完了タスク/Todo）===
  # 並び順は position → id、削除時は配下タスクも削除
  has_many :goal_tasks, -> { order(:position, :id) }, dependent: :destroy

  # --- バリデーション ---
  validates :title,            presence: true, length: { maximum: 60 }
  validates :description,      presence: true, length: { maximum: 1000 }
  validates :success_criteria, presence: true, length: { maximum: 500 }
  validates :category_id,      presence: true
  validates :visibility,       presence: true
  validates :share_summary,    length: { maximum: 140 }, allow_blank: true

  # --- 可視性スコープ ---
  scope :visible_to, ->(viewer) {
    return none if viewer.nil?
    where(
      arel_table[:visibility].eq(visibilities[:public])
      .or(
        arel_table[:visibility].eq(visibilities[:followers])
        .and(arel_table[:user_id].in(viewer.following_ids + [viewer.id]))
      )
      .or(
        arel_table[:visibility].eq(visibilities[:private])
        .and(arel_table[:user_id].eq(viewer.id))
      )
    )
  }

  # --- ビュー/集計用ヘルパ ---
  # ログインユーザーがこのGoalをお気に入り済みか
  def favorited_by?(user)
    return false if user.blank?
    favorites.exists?(user_id: user.id)
  end

  # タスク進捗（%）。小数点四捨五入
  def progress_ratio
    total = tasks_count
    return 0 if total.zero?
    ((tasks_done_count.to_f / total) * 100).round
  end

  # 完了/総数（N+1を避けたい場合は呼び出し側で includes(:goal_tasks) 推奨）
  def tasks_done_count
    goal_tasks.where.not(completed_at: nil).count
  end

  def tasks_count
    goal_tasks.count
  end
end
