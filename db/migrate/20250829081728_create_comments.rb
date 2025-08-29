class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :log,  null: false, foreign_key: true
      t.timestamps
    end
    add_index :comments, [:log_id, :created_at]
  end
end
