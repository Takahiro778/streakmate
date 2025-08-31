class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.time :bedtime_time, null: false, default: "2000-01-01 23:00:00" # 23:00固定の初期値
      t.boolean :bedtime_enabled, null: false, default: false
      t.string :time_zone, null: false, default: "Asia/Tokyo"
      t.timestamps
    end
  end
end
