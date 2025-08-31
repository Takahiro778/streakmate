class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # 通知（本人宛ては作らない）
  after_create_commit :notify_followed

  private

  def notify_followed
    return if follower_id == followed_id
    Notification.create!(
      user_id: followed_id, actor_id: follower_id,
      notifiable: self, action: :followed
    )
  end
end
