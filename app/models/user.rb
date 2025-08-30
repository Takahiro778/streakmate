class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :profile, dependent: :destroy, inverse_of: :user
  has_many :goals,   dependent: :destroy
  has_many :logs,    dependent: :destroy

  # === Cheer / Comment ===
  has_many :cheers, dependent: :destroy
  has_many :cheered_logs, through: :cheers, source: :log
  has_many :comments, dependent: :destroy

  # === Favorite（Goal のブックマーク）===  ← 追加
  has_many :favorites, dependent: :destroy
  has_many :favorited_goals, through: :favorites, source: :goal

  # === Follow（自己結合）===
  # 自分→他人（フォローしている側）
  has_many :active_follows,  class_name: "Follow",
                             foreign_key: :follower_id,
                             dependent: :destroy,
                             inverse_of: :follower
  has_many :following, through: :active_follows, source: :followed

  # 他人→自分（フォロワー）
  has_many :passive_follows, class_name: "Follow",
                             foreign_key: :followed_id,
                             dependent: :destroy,
                             inverse_of: :followed
  has_many :followers, through: :passive_follows, source: :follower

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

  # === Follow ヘルパ ===
  def following?(other_user)
    return false if other_user.blank? || other_user.id == id
    following.exists?(other_user.id)
  end

  # 既存コード互換：Log.visible_to / timeline 用に同名メソッドを本実装へ差し替え
  def following_ids
    # 1リクエスト内での参照が多い想定なので軽くメモ化
    @following_ids ||= following.ids
  end

  # 便利メソッド（任意で使用）
  def follow!(other_user)
    return false if other_user.id == id
    active_follows.create_or_find_by!(followed: other_user)
  end

  def unfollow!(other_user)
    active_follows.destroy_by(followed: other_user)
  end

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).+\z/)
      errors.add(:password, 'must include both letters and numbers')
    end
  end
end
