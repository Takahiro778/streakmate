class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User",
                        inverse_of: :active_follows,
                        counter_cache: :followings_count
  belongs_to :followed, class_name: "User",
                        inverse_of: :passive_follows,
                        counter_cache: :followers_count

  # 同一ペアの二重登録を禁止
  validates :follower_id, uniqueness: { scope: :followed_id }
  # 自己フォローを禁止
  validate  :not_self_follow

  # 通知（本人宛ては作らない／バリデで弾くが念のためガード）
  after_create_commit :notify_followed

  private

  def not_self_follow
    if follower_id.present? && follower_id == followed_id
      errors.add(:base, "cannot follow self")
    end
  end

  def notify_followed
    return if follower_id == followed_id
    Notification.create!(
      user_id:    followed_id,
      actor_id:   follower_id,
      notifiable: self,
      action:     :followed
    )
  end
end
