class DashboardsController < ApplicationController
  before_action :authenticate_user!  # まだなら追加

  def show
    base = Log.where(user_id: current_user.id).for_month
    @pie_data = base.group(:category).sum(:minutes)
    @total_minutes = @pie_data.values.sum
  end
end
