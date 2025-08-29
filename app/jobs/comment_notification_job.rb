class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(:user, :log).find_by(id: comment_id)
    return unless comment

    recipient = comment.log.user   # 通知の受け手＝ログ作者
    actor     = comment.user       # 行為者＝コメント投稿者
    return if recipient.id == actor.id  # 自分宛ては通知しない

    Notification.create!(
      recipient:  recipient,
      actor:      actor,
      notifiable: comment,
      action:     "commented"
    )
  end
end
