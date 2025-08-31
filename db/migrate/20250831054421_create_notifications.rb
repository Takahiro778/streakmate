class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user,  null: false, foreign_key: true                 # 受信者
      t.references :actor, null: false, foreign_key: { to_table: :users } # 起票者(User)
      t.references :notifiable, null: false, polymorphic: true            # 多態
      t.integer :action, null: false                                      # 0:commented,1:cheered,2:followed
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, [:user_id, :read_at]
    add_index :notifications, [:notifiable_type, :notifiable_id]
  end
end
