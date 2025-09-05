class DashboardsController < ApplicationController
  def show
    @pie_data      = Log.sum_minutes_by_category_for_month
    @total_minutes = @pie_data.values.sum
  end
end
