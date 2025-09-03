class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  has_one_attached :avatar

  # 表示名・自己紹介
  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :introduction, length: { maximum: 300 }, allow_blank: true

  # 画像バリデーション（1メソッドでまとめて実行）
  validate :validate_avatar

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/webp image/jpg].freeze
  NORMALIZED_TYPES      = { 'image/jpg' => 'image/jpeg' }.freeze
  MAX_AVATAR_SIZE       = 2.megabytes

  private

  def validate_avatar
    return unless avatar.attached?

    # blob がまだ解析前でも content_type/byte_size は参照可（nil の可能性に備える）
    blob = avatar.blob
    return errors.add(:avatar, 'のアップロードに失敗しました') if blob.nil?

    # --- MIMEタイプを正規化 ---
    content_type = (blob.content_type.presence || '').downcase
    content_type = NORMALIZED_TYPES.fetch(content_type, content_type)

    # --- タイプの検証 ---
    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      errors.add(:avatar, 'は PNG / JPG / JPEG / WEBP のいずれかにしてください')
    end

    # --- サイズの検証 ---
    size = blob.byte_size
    if size.nil?
      # 極めて稀に解析未完などで nil のことがあるためフォールバック
      errors.add(:avatar, 'のサイズ取得に失敗しました。別の画像でお試しください')
      return
    end

    if size > MAX_AVATAR_SIZE
      errors.add(:avatar, 'は 2MB 以下にしてください')
    end
  end
end
