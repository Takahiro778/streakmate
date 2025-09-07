class GoalTasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_task, only: [:update, :destroy, :move]

  def create
    @task = @goal.goal_tasks.build(
      task_params.merge(position: (@goal.goal_tasks.maximum(:position) || 0) + 1)
    )
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

  # === 追加: D&Dで受ける一括並び替え ===
  # PATCH /goals/:goal_id/goal_tasks/reorder
  # payload: { ordered_ids: ["5","3","9", ...] }
  def reorder
    ids = Array(params[:ordered_ids]).map(&:to_i)
    return head :bad_request if ids.blank?

    # 受け取ったIDのうち、このgoalに属するものだけを対象にする
    valid_ids = @goal.goal_tasks.where(id: ids).pluck(:id)
    return head :bad_request if valid_ids.empty?

    # 並び順は0始まりで再採番
    GoalTask.transaction do
      valid_ids.each_with_index do |id, idx|
        GoalTask.where(id: id, goal_id: @goal.id).update_all(position: idx)
      end
    end

    head :no_content
  end

  # === 追加: 矢印ボタンで1つずつ移動 ===
  # PATCH /goals/:goal_id/goal_tasks/:id/move?move=up|down
  def move
    dir = params[:move].to_s
    current_pos = @task.position.to_i

    case dir
    when "up"
      target_pos = [current_pos - 1, 0].max
    when "down"
      max_pos = @goal.goal_tasks.maximum(:position).to_i
      target_pos = [current_pos + 1, max_pos].min
    else
      return head :bad_request
    end

    # 入れ替え対象（同じgoal内で指定positionのもの）
    swap = @goal.goal_tasks.find_by(position: target_pos)

    GoalTask.transaction do
      if swap
        swap.update!(position: current_pos)
      end
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
