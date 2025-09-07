class AddPositionToGoalTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :goal_tasks, :position, :integer
    add_index  :goal_tasks, [:goal_id, :position]
  end
end
