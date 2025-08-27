class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy, inverse_of: :user
  accepts_nested_attributes_for :profile

  validates :nickname, presence: true

  # 入力があるときだけ複雑性チェック
  validate :password_complexity, if: -> { password.present? }

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/\A(?=.*[A-Za-z])(?=.*\d).+\z/)
      errors.add(:password, 'must include both letters and numbers')
    end
  end
end
