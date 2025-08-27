class GoalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @goals = Goal.visible_to(current_user).order(created_at: :desc)
  end

  def new
    @goal = current_user.goals.build(visibility: :public)
  end

  def create
    @goal = current_user.goals.build(goal_params)
    if @goal.save
      redirect_to goals_path, notice: '目標を作成しました'
    else
      flash.now[:alert] = '入力内容を確認してください'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def goal_params
    params.require(:goal).permit(:title, :description, :category_id, :visibility, :success_criteria, :share_summary)
  end
end
