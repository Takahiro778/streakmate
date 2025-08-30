class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :goal, counter_cache: :favorites_count

  validates :user_id, uniqueness: { scope: :goal_id }
end
