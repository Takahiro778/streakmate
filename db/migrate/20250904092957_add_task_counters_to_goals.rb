class AddTaskCountersToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :tasks_count, :integer, null: false, default: 0
    add_column :goals, :tasks_done_count, :integer, null: false, default: 0
  end
end
