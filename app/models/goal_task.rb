# frozen_string_literal: true
class GoalTask < ApplicationRecord
  belongs_to :goal
  # ※ goal_tasks に user_id が無いなら、下行は削除してOK
  belongs_to :user, optional: true

  validates :title, presence: true

  # 完了管理は completed_at(datetime) で行う
  scope :completed,  -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def completed?
    completed_at.present?
  end

  # 並び順（未設定は末尾扱い）
  default_scope { order(Arel.sql("COALESCE(position, 999999), created_at ASC")) }

  before_create :assign_tail_position

  private

  def assign_tail_position
    return if position.present?
    max = self.class.where(goal_id: goal_id).maximum(:position)
    self.position = (max || -1) + 1
  end
end
