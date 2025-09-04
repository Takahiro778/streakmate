class Comment < ApplicationRecord
  include ActionView::RecordIdentifier   # ← これを追加

  MIN_INTERVAL = 3.seconds
  MAX_LEN      = 200

  belongs_to :user
  belongs_to :log

  validates :body, presence: true, length: { maximum: MAX_LEN }
  validate  :respect_min_interval

  # ===== Turbo Streams（タイムライン/他タブに即時反映）=====
  after_create_commit  -> {
    broadcast_prepend_later_to(
      [log, :comments_stream],
      target: dom_id(log, :comments),      # ← ここで dom_id が使えるようになる
      partial: "comments/comment",
      locals: { comment: self }
    )
  }

  after_update_commit  -> {
    broadcast_replace_later_to(
      [log, :comments_stream],
      target: dom_id(self),                # <turbo-frame id="comment_..."> を差し替え
      partial: "comments/comment",
      locals: { comment: self }
    )
  }

  after_destroy_commit -> {
    broadcast_remove_to(
      [log, :comments_stream],
      target: dom_id(self)
    )
  }

  private

  def respect_min_interval
    return if user_id.blank?
    recent_exists = Comment.where(user_id: user_id)
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
