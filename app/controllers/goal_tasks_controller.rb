class GoalTasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_task, only: [:update, :destroy]

  def create
    @task = @goal.goal_tasks.build(task_params.merge(position: (@goal.goal_tasks.maximum(:position) || 0) + 1))
    if @task.save
      redirect_to @goal, notice: "タスクを追加しました。"
    else
      redirect_to @goal, alert: "追加に失敗しました。"
    end
  end

  def update
    if toggle_param?
      @task.completed? ? @task.reopen! : @task.complete!
      redirect_to @goal, notice: "タスクを更新しました。"
    elsif @task.update(task_params)
      redirect_to @goal, notice: "タスクを更新しました。"
    else
      redirect_to @goal, alert: "更新に失敗しました。"
    end
  end

  def destroy
    @task.destroy
    redirect_to @goal, notice: "タスクを削除しました。"
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def set_task
    @task = @goal.goal_tasks.find(params[:id])
  end

  def task_params
    params.fetch(:goal_task, {}).permit(:title, :estimated_minutes, :due_on, :position)
  end

  def toggle_param?
    params[:toggle].present?
  end
end
