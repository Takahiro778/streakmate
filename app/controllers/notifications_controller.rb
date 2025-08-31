class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .order(created_at: :desc)
                                 .limit(100)
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.read!
    respond_to(&:turbo_stream)
  end

  def read_all
    current_user.notifications.unread.update_all(read_at: Time.current, updated_at: Time.current)
    respond_to(&:turbo_stream)
  end
end
