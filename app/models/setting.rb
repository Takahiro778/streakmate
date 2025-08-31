class Setting < ApplicationRecord
  belongs_to :user

  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
  validates :bedtime_time, presence: true
end
