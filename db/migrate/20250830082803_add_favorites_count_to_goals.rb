class AddFavoritesCountToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :favorites_count, :integer, null: false, default: 0
  end
end
