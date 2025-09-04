class AddTaskCountersToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :tasks_count, :integer
    add_column :goals, :tasks_done_count, :integer
  end
end
