class AddVisibilityToLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :logs, :visibility, :integer, null: false, default: 0
    add_index  :logs, :created_at
    add_index  :logs, :user_id
  end
end
