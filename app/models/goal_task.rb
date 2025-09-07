class GoalTask < ApplicationRecord
  belongs_to :goal
  belongs_to :user  # もし持っているなら

  # 既存のスコープやenum…（省略）

  # 並び順は position ASC → 未設定は最後尾扱い
  default_scope { order(Arel.sql("COALESCE(position, 999999), created_at ASC")) }

  before_create :assign_tail_position

  private

  def assign_tail_position
    return if self.position.present?
    max = GoalTask.where(goal_id: goal_id).maximum(:position)
    self.position = (max || -1) + 1
  end
end
