class Notification < ApplicationRecord
  belongs_to :user            # ← 受信者
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  enum action: { commented: 0, cheered: 1, followed: 2 }
  scope :unread, -> { where(read_at: nil) }
  validates :action, presence: true
end
