class AddGoalRefsToLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :logs, :goal, foreign_key: true, null: true
    add_reference :logs, :goal_task, foreign_key: true, null: true
  end
end
