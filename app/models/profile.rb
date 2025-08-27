class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  # アイコンは Profile 側に保持
  has_one_attached :avatar

  # 表示名・自己紹介の上限はお好みで
  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :introduction, length: { maximum: 300 }, allow_blank: true

  # 画像バリデーション（容量・拡張子）
  validate :avatar_type
  validate :avatar_size

  private

  def avatar_type
    return unless avatar.attached?
    unless avatar.content_type.in?(%w[image/png image/jpg image/jpeg image/webp])
      errors.add(:avatar, 'must be PNG/JPG/JPEG/WEBP')
    end
  end

  def avatar_size
    return unless avatar.attached?
    if avatar.blob.byte_size > 2.megabytes
      errors.add(:avatar, 'must be 2MB or smaller')
    end
  end
end
