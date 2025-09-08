class Comment < ApplicationRecord
  include ActionView::RecordIdentifier

  MIN_INTERVAL = 3.seconds
  MAX_LEN      = 200

  belongs_to :user
  belongs_to :log, touch: true

  validates :body, presence: true, length: { maximum: MAX_LEN }
  # 連投制限は「新規作成時のみ」チェック（編集で弾かれないように）
  validate  :respect_min_interval, on: :create

  # ===== Turbo Streams（即時反映）=====
  # 一覧のラッパーIDは views/comments/section.html.erb 側で id="comments_list"
  after_create_commit  -> {
    broadcast_append_later_to(
      [log, :comments_stream],
      target:  "comments_list",
      partial: "comments/comment",
      locals:  { comment: self }
    )
  }

  after_update_commit  -> {
    broadcast_replace_later_to(
      [log, :comments_stream],
      target:  dom_id(self),              # <turbo-frame id="comment_..."> を置換
      partial: "comments/comment",
      locals:  { comment: self }
    )
  }

  after_destroy_commit -> {
    broadcast_remove_to(
      [log, :comments_stream],
      target: dom_id(self)
    )
  }

  # ログ主への通知（自分自身には通知しない）
  after_create_commit :notify_owner

  private

  def respect_min_interval
    return if user_id.blank?
    recent_exists = Comment.where(user_id: user_id)
                           .where('created_at > ?', Time.current - MIN_INTERVAL)
                           .exists?
    errors.add(:base, "短時間に連投はできません") if recent_exists
  end

  def notify_owner
    return if log.user_id == user_id
    Notification.create!(
      user_id: log.user_id,
      actor_id: user_id,
      notifiable: self,
      action: :commented
    )
  end
end
