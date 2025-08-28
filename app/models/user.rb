class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :profile, dependent: :destroy, inverse_of: :user
  has_many :goals,   dependent: :destroy
  has_many :logs,    dependent: :destroy

  validates :nickname, presence: true

  # 入力があるときだけ複雑性チェック
  validate :password_complexity, if: -> { password.present? }

  # ===== Streak / Weekly summary =====
  # 1日1回以上のログがあれば連続日数をカウント
  def streak_days
    streak = 0
    today  = Time.zone.today

    # 今日から遡って、ログがある日を連続カウント
    loop do
      break unless logs.on_day(today - streak).exists?
      streak += 1
    end

    streak
  end

  # 今週の合計分（minutes）
  # all_week はデフォルトで日曜始まり
  def weekly_minutes
    logs.this_week.sum(:minutes)
  end
  # ===================================

  # フォロー機能が未実装なのでダミーを返す
  def following_ids
    [] # 後で Follow 実装時に差し替え
  end

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).+\z/)
      errors.add(:password, 'must include both letters and numbers')
    end
  end
end
