class Comment < ApplicationRecord
  MIN_INTERVAL = 3.seconds  # 連投制限（最小間隔）
  MAX_LEN      = 200

  belongs_to :user
  belongs_to :log

  validates :body, presence: true, length: { maximum: MAX_LEN }
  validate  :respect_min_interval

  # 通知（本人宛ては作らない）
  after_create_commit :notify_owner

  private

  def respect_min_interval
    return if user_id.blank?
    recent_exists =
      Comment.where(user_id: user_id)
             .where('created_at > ?', Time.current - MIN_INTERVAL)
             .exists?
    errors.add(:base, "短時間に連投はできません") if recent_exists
  end

  def notify_owner
    owner_id = log.user_id
    return if owner_id == user_id
    Notification.create!(
      user_id: owner_id, actor_id: user_id,
      notifiable: self, action: :commented
    )
  end
end
