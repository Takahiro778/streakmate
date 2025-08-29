class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :profile, dependent: :destroy, inverse_of: :user
  has_many :goals,   dependent: :destroy
  has_many :logs,    dependent: :destroy
  has_many :cheers, dependent: :destroy
  has_many :cheered_logs, through: :cheers, source: :log

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

  # フォロー機能が未実装なので暫定対応
  # - 開発環境のみ、自分以外のユーザー最大10人を「フォロー中」とみなす
  # - 環境変数 DEMO_FOLLOWING_IDS（例: "2,3,5"）があればそれを優先
  # - 本実装時に Follow モデルへ差し替え予定
  def following_ids
    return [] unless Rails.env.development?

    if ENV["DEMO_FOLLOWING_IDS"].present?
      ENV["DEMO_FOLLOWING_IDS"].split(",").map(&:strip).map!(&:to_i).uniq - [id]
    else
      User.where.not(id: id).order(:id).limit(10).pluck(:id)
    end
  end

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).+\z/)
      errors.add(:password, 'must include both letters and numbers')
    end
  end
end
