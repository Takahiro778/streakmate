class GoalTask < ApplicationRecord
  belongs_to :goal
  scope :completed,  -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def completed?  = completed_at.present?
  def complete!    = update!(completed_at: Time.current)
  def reopen!      = update!(completed_at: nil)
end
