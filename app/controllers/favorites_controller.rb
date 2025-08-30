class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :forbid_invisible_goal!  # 非公開は登録/解除も不可

  def create
    current_user.favorites.create_or_find_by!(goal: @goal)
    @goal.reload
    respond_to(&:turbo_stream)
  rescue ActiveRecord::RecordNotUnique
    @goal.reload
    respond_to(&:turbo_stream)
  end

  def destroy
    current_user.favorites.destroy_by(goal: @goal)
    @goal.reload
    respond_to(&:turbo_stream)
  end

  private
  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  # 目標が非公開ならブロック（実装に合わせて調整）
  def forbid_invisible_goal!
    if @goal.respond_to?(:visibility_public?) && !@goal.visibility_public?
      head :forbidden
    end
  end
end
