class AddUniqueIndexToFollows < ActiveRecord::Migration[7.1]
  INDEX_NAME = "index_follows_on_follower_id_and_followed_id"

  def up
    # 既存の同名インデックスがある場合はユニークかどうかで処理を分岐
    if index_exists?(:follows, [:follower_id, :followed_id], name: INDEX_NAME, unique: true)
      # すでにユニークなら何もしない
      say "Index #{INDEX_NAME} already unique. Skipping."
    else
      remove_index :follows, name: INDEX_NAME if index_exists?(:follows, [:follower_id, :followed_id], name: INDEX_NAME)
      add_index    :follows, [:follower_id, :followed_id], unique: true, name: INDEX_NAME
    end
  end

  def down
    # 元に戻す（ユニークを外して非ユニークで作り直す or 何もしない運用でも可）
    remove_index :follows, name: INDEX_NAME if index_exists?(:follows, [:follower_id, :followed_id], name: INDEX_NAME)
    add_index    :follows, [:follower_id, :followed_id], name: INDEX_NAME unless index_exists?(:follows, [:follower_id, :followed_id], name: INDEX_NAME)
  end
end
