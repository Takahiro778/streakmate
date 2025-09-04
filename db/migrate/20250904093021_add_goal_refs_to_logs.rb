class AddGoalRefsToLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :logs, :goal, null: false, foreign_key: true
    add_reference :logs, :goal_task, null: false, foreign_key: true
  end
end
