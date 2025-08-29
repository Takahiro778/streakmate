class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(:user, :log).find_by(id: comment_id)
    return unless comment

    log       = comment.log
    recipient = log.user        # ログの作者
    actor     = comment.user

    # 自分のログに自分でコメント → 通知しない
    return if recipient.id == actor.id

    Notification.create!(
      recipient:  recipient,
      actor:      actor,
      notifiable: comment,
      action:     "commented"
    )

    # 将来リアルタイム配信するなら（任意・今は入口だけ）
    # Turbo::StreamsChannel.broadcast_prepend_to(
    #   "notifications_user_#{recipient.id}",
    #   target: "notifications",
    #   partial: "notifications/item",
    #   locals: { notification: notification }
    # )
  end
end
