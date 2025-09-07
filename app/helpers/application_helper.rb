module ApplicationHelper
  # ユーザーの未読通知数を安全に取得するヘルパ
  def unread_notifications_count(user)
    return 0 unless user&.respond_to?(:notifications)

    rel = user.notifications

    # スコープ unread があれば利用
    if rel.respond_to?(:unread)
      rel.unread.count

    # よくあるカラム read_at で未読判定
    elsif rel.klass.column_names.include?("read_at")
      rel.where(read_at: nil).count

    # 既読フラグ read がある場合
    elsif rel.klass.column_names.include?("read")
      rel.where(read: false).count

    else
      0
    end
  end
end
