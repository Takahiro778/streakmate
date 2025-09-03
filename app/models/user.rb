class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :profile, dependent: :destroy, inverse_of: :user
  has_many :goals,   dependent: :destroy
  has_many :logs,    dependent: :destroy
  has_one_attached :avatar

  # === Cheer / Comment ===
  has_many :cheers, dependent: :destroy
  has_many :cheered_logs, through: :cheers, source: :log
  has_many :comments, dependent: :destroy

  # === Favorite（Goal のブックマーク）===
  has_many :favorites, dependent: :destroy
  has_many :favorited_goals, through: :favorites, source: :goal

  # === Notification（通知）===
  has_many :notifications, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification",
                                foreign_key: :actor_id, dependent: :nullify

  # === Follow（自己結合）===
  has_many :active_follows,  class_name: "Follow",
                             foreign_key: :follower_id,
                             dependent: :destroy,
                             inverse_of: :follower
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow",
                             foreign_key: :followed_id,
                             dependent: :destroy,
                             inverse_of: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # === Setting（就寝リマインダーなどの設定）===
  has_one  :setting, dependent: :destroy, inverse_of: :user
  after_create :ensure_setting!

  validates :nickname, presence: true
  validate :password_complexity, if: -> { password.present? }

  # ===== Streak / Weekly summary =====
  def streak_days
    streak = 0
    today  = Time.zone.today
    loop do
      break unless logs.on_day(today - streak).exists?
      streak += 1
    end
    streak
  end

  def weekly_minutes
    logs.this_week.sum(:minutes)
  end
  # ===================================

  # === Follow ヘルパ（Pundit から呼ぶ想定）===
  # アソシエーションを読み込まずに follow 関係テーブルへ直接 exists? を投げる
  def follows?(other_user)
    return false if other_user.blank? || other_user.id == id
    active_follows.exists?(followed_id: other_user.id)
  end
  alias_method :following?, :follows?

  # キャッシュしたい場合のみ使用（件数が多いときは注意）
  def following_ids
    @following_ids ||= active_follows.pluck(:followed_id)
  end

  def follow!(other_user)
    return false if other_user.blank? || other_user.id == id
    active_follows.create_or_find_by!(followed: other_user)
  end

  def unfollow!(other_user)
    active_follows.destroy_by(followed: other_user)
  end

  # === Setting の初期生成（public）===
  def ensure_setting!
    setting || create_setting!(
      bedtime_time:     Time.zone.parse("23:00"),
      bedtime_enabled:  false,
      time_zone:        Time.zone.tzinfo.name # 例: "Asia/Tokyo"
    )
  end

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).+\z/)
      errors.add(:password, 'must include both letters and numbers')
    end
  end
end
