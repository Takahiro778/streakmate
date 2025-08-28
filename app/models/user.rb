class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :profile, dependent: :destroy, inverse_of: :user
  has_many :goals,   dependent: :destroy
  has_many :logs,    dependent: :destroy 

  validates :nickname, presence: true

  # 入力があるときだけ複雑性チェック
  validate :password_complexity, if: -> { password.present? }

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
