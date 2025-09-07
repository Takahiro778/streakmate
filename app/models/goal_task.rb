class GoalTask < ApplicationRecord
  belongs_to :goal
  # userを持たない環境もある想定なので optional にしておくと安全
  belongs_to :user, optional: true

  # 必要ならバリデーション
  validates :title, presence: true, allow_blank: false

  # ── 完了状態（boolean想定） ───────────────────────────────
  # DBに completed:boolean がある前提
  attribute :completed, :boolean, default: false

  scope :completed,  -> { where(completed: true) }
  scope :incomplete, -> { where(completed: [false, nil]) }

  # コントローラで使っている操作メソッド
  def complete!
    update!(completed: true)
  end

  def reopen!
    update!(completed: false)
  end

  # ── 並び順（position ASC、未設定は最後尾扱い） ───────────────
  default_scope { order(Arel.sql("COALESCE(position, 999999), created_at ASC")) }

  before_create :assign_tail_position

  private

  def assign_tail_position
    return if self.position.present?
    max = GoalTask.where(goal_id: goal_id).maximum(:position)
    self.position = (max || -1) + 1
  end
end
