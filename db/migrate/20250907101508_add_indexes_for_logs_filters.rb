class AddIndexesForLogsFilters < ActiveRecord::Migration[7.1]
  def change
    add_index :logs, :created_at unless index_exists?(:logs, :created_at)
    add_index :logs, [:user_id, :created_at] unless index_exists?(:logs, [:user_id, :created_at])
    add_index :logs, :visibility unless index_exists?(:logs, :visibility)
  end
end
