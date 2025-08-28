class CreateLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :logs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :minutes
      t.integer :category
      t.text :memo

      t.timestamps
    end
  end
end
