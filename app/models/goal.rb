class Goal < ApplicationRecord
  belongs_to :user

  # 公開範囲（衝突回避のため _prefix を付与）
  enum visibility: { public: 0, followers: 1, private: 2 }, _prefix: :visibility
  # 例: visibility_public?, visibility_followers?, visibility_private?

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category

  # === Favorite（ブックマーク）===  ← 追加
  has_many :favorites,  dependent: :destroy
  has_many :favoriters, through: :favorites, source: :user

  # ログインユーザーがこのGoalをお気に入り済みか（ビュー用ヘルパ）
  def favorited_by?(user)
    return false if user.blank?
    favorites.exists?(user_id: user.id)
  end

  validates :title,            presence: true, length: { maximum: 60 }
  validates :description,      presence: true, length: { maximum: 1000 }
  validates :success_criteria, presence: true, length: { maximum: 500 }
  validates :category_id,      presence: true
  validates :visibility,       presence: true
  validates :share_summary,    length: { maximum: 140 }, allow_blank: true

  scope :visible_to, ->(viewer) {
    return none if viewer.nil?
    where(
      arel_table[:visibility].eq(visibilities[:public])
      .or(
        arel_table[:visibility].eq(visibilities[:followers])
        .and(arel_table[:user_id].in(viewer.following_ids + [viewer.id]))
      )
      .or(
        arel_table[:visibility].eq(visibilities[:private])
        .and(arel_table[:user_id].eq(viewer.id))
      )
    )
  }
end
