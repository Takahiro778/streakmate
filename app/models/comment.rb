class Comment < ApplicationRecord
  MIN_INTERVAL = 3.seconds  # 連投制限（最小間隔）
  MAX_LEN      = 200

  belongs_to :user
  belongs_to :log

  validates :body, presence: true, length: { maximum: MAX_LEN }
  validate  :respect_min_interval

  after_create_commit :enqueue_notification # 通知連携（後述フック）

  private

  def respect_min_interval
    return if user_id.blank?
    recent_exists =
      Comment.where(user_id: user_id)
             .where('created_at > ?', Time.current - MIN_INTERVAL)
             .exists?
    errors.add(:base, "短時間に連投はできません") if recent_exists
  end

  def enqueue_notification
  ::CommentNotificationJob.perform_later(id)
  end
end
