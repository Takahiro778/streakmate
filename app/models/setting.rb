class Setting < ApplicationRecord
  belongs_to :user

  # tzinfo の識別子（例: "Asia/Tokyo", "UTC"）で保存する
  validates :time_zone, presence: true,
                        inclusion: { in: ActiveSupport::TimeZone.all.map { |z| z.tzinfo.name } }
  validates :bedtime_time, presence: true
end
