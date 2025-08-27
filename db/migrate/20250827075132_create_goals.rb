class CreateGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.text :success_criteria
      t.integer :category_id
      t.integer :visibility
      t.string :share_summary

      t.timestamps
    end
  end
end
