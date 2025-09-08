# frozen_string_literal: true
class GoalTasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_task, only: [:update, :destroy, :move]

  def create
  @task = @goal.goal_tasks.build(
    task_params.merge(position: (@goal.goal_tasks.maximum(:position) || 0) + 1)
  )

  if @task.save
    respond_to do |format|
      format.turbo_stream   # => 上の create.turbo_stream.erb を自動描画
      format.html { redirect_to @goal, notice: "タスクを追加しました。" }
    end
  else
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html { redirect_to @goal, alert: "追加に失敗しました。" }
    end
  end
end


  # 完了トグル：completed_at を ON/OFF
  # 完了にしたら行を remove、未完了へ戻したら行を replace
  def update
    if toggle_param?
      new_completed = !@task.completed?
      @task.update!(completed_at: (new_completed ? Time.current : nil))

      respond_to do |format|
        format.turbo_stream do
          if new_completed
            render turbo_stream: turbo_stream.remove(helpers.dom_id(@task))
          else
            render turbo_stream: turbo_stream.replace(
              helpers.dom_id(@task),
              partial: "goals/task",
              locals:  { task: @task, goal: @goal }
            )
          end
        end
        format.html { redirect_to @goal, notice: "タスクを更新しました。" }
      end
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

  def reorder
    ids = Array(params[:ordered_ids]).map(&:to_i)
    return head :bad_request if ids.blank?

    valid_ids = @goal.goal_tasks.where(id: ids).pluck(:id)
    return head :bad_request if valid_ids.empty?

    GoalTask.transaction do
      valid_ids.each_with_index do |id, idx|
        GoalTask.where(id: id, goal_id: @goal.id).update_all(position: idx)
      end
    end

    head :no_content
  end

  def move
    dir = params[:move].to_s
    current_pos = @task.position.to_i

    target_pos =
      case dir
      when "up"   then [current_pos - 1, 0].max
      when "down" then [current_pos + 1, @goal.goal_tasks.maximum(:position).to_i].min
      else return head :bad_request
      end

    swap = @goal.goal_tasks.find_by(position: target_pos)

    GoalTask.transaction do
      swap&.update!(position: current_pos)
      @task.update!(position: target_pos)
    end

    respond_to do |format|
      format.turbo_stream { head :no_content }
      format.html { redirect_to @goal, notice: "タスクの順序を更新しました。" }
    end
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
