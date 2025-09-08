class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal,     only: [:show]
  before_action :set_own_goal, only: [:edit, :update, :destroy]

  def index
    @goals = Goal.visible_to(current_user)
                 .includes(:user)
                 .order(created_at: :desc)
  end

  def show
    return unless @goal
    unless allowed_to_view?(@goal, current_user)
      redirect_to goals_path, alert: 'この目標を閲覧する権限がありません' and return
    end

    # ✅ リロード時も「未完のみ」表示
    @tasks = @goal.goal_tasks.incomplete
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

  def edit; end

  def update
    if @goal.update(goal_params)
      redirect_to goal_path(@goal), notice: '目標を更新しました'
    else
      flash.now[:alert] = '入力内容を確認してください'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy!
    redirect_to goals_path, notice: '目標を削除しました'
  end

  private

  def set_goal
    @goal = Goal.find_by(id: params[:id])
    return if @goal.present?
    redirect_to goals_path, alert: '指定の目標は見つかりませんでした'
  end

  def set_own_goal
    @goal = current_user.goals.find_by(id: params[:id])
    return if @goal.present?
    redirect_to goals_path, alert: '編集・削除できるのは自分の目標だけです'
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :category_id, :visibility, :success_criteria, :share_summary)
  end

  def allowed_to_view?(goal, viewer)
    return false if viewer.nil?
    return true  if goal.visibility_public?
    return goal.user_id == viewer.id if goal.visibility_private?
    goal.user_id == viewer.id || viewer.following_ids.include?(goal.user_id)
  end
end
