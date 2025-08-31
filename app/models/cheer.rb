class Cheer < ApplicationRecord
  belongs_to :user
  belongs_to :log, counter_cache: true

  validates :user_id, uniqueness: { scope: :log_id }
  validate  :cannot_cheer_own_log

  # 通知（本人宛ては作らない）
  after_create_commit :notify_owner

  private

  def cannot_cheer_own_log
    return if log.blank? || user.blank?
    errors.add(:base, "自分の投稿には応援できません") if log.user_id == user_id
  end

  def notify_owner
    return if log.blank? || user_id == log.user_id
    Notification.create!(
      user_id: log.user_id, actor_id: user_id,
      notifiable: self, action: :cheered
    )
  end
end
