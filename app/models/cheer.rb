class Cheer < ApplicationRecord
  belongs_to :user
  belongs_to :log, counter_cache: true

  validates :user_id, uniqueness: { scope: :log_id }
  validate  :cannot_cheer_own_log

  private

  def cannot_cheer_own_log
    return if log.blank? || user.blank?
    errors.add(:base, "自分の投稿には応援できません") if log.user_id == user_id
  end
end
