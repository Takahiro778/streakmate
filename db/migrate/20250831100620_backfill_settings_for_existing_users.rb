class BackfillSettingsForExistingUsers < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Backfilling settings for users without one" do
      # モデルのカラム情報を念のため最新化
      User.reset_column_information
      Setting.reset_column_information

      created = 0
      User.find_each do |u|
        next if Setting.exists?(user_id: u.id)

        # tzinfo 名で保存（例: "Asia/Tokyo"）
        tz = Time.zone.tzinfo.name

        Setting.create!(
          user_id:         u.id,
          bedtime_time:    Time.zone.parse("23:00"),
          bedtime_enabled: false,
          time_zone:       tz
        )
        created += 1
      rescue => e
        Rails.logger.warn "Backfill failed for user #{u.id}: #{e.class} #{e.message}"
      end
      created
    end
  end

  def down
    # 取り消しは行わない（no-op）
  end
end
