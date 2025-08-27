class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  has_one_attached :avatar

  # 表示名・自己紹介
  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :introduction,  length: { maximum: 300 }, allow_blank: true

  # 画像バリデーション
  validate :validate_avatar_type
  validate :validate_avatar_size

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpg image/jpeg image/webp].freeze
  MAX_AVATAR_SIZE       = 2.megabytes

  private

  # 拡張子／MIME タイプ
  def validate_avatar_type
    return unless avatar.attached?

    unless ALLOWED_CONTENT_TYPES.include?(avatar.content_type)
      errors.add(:avatar, 'は PNG / JPG / JPEG / WEBP のいずれかにしてください')
    end
  end

  # ファイルサイズ
  def validate_avatar_size
    return unless avatar.attached?

    if avatar.blob.byte_size > MAX_AVATAR_SIZE
      errors.add(:avatar, 'は 2MB 以下にしてください')
    end
  end
end
