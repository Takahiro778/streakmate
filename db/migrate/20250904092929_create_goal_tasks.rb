class CreateGoalTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :goal_tasks do |t|
      t.references :goal, null: false, foreign_key: true
      t.string :title, limit: 100
      t.integer :estimated_minutes
      t.integer :position
      t.date :due_on
      t.datetime :completed_at

      t.timestamps
    end
  end
end
