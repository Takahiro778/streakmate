class CreateCheers < ActiveRecord::Migration[7.1]
  def change
    create_table :cheers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :log,  null: false, foreign_key: true
      t.timestamps
    end
    # 同一ユーザーが同一ログに重複付与しない
    add_index :cheers, [:user_id, :log_id], unique: true
  end
end
