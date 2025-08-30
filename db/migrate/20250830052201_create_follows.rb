class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      # ここを修正（foreign_key: { to_table: :users } を付ける）
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    # 重複防止
    add_index :follows, [:follower_id, :followed_id], unique: true
    # 自己フォロー禁止（DBが対応していれば有効：PostgreSQL/SQLite/MySQL8+）
    add_check_constraint :follows, "follower_id <> followed_id", name: "no_self_follow"
  end
end
