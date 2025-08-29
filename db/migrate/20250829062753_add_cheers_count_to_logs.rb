class AddCheersCountToLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :logs, :cheers_count, :integer, null: false, default: 0
  end
end
