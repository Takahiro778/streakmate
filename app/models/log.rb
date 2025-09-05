class Log < ApplicationRecord
  belongs_to :user

  # === Cheer（応援）関連 ===
  has_many :cheers, dependent: :destroy
  has_many :cheerers, through: :cheers, source: :user

  # === Comment（コメント）関連 ===
  has_many :comments, dependent: :destroy

  # ログが user に応援されているか（ビュー側の分岐で使用）
  def cheered_by?(user)
    return false if user.blank?
    cheers.exists?(user_id: user.id)
  end

  # --- 共通判定: 可視性チェック（Pundit からもビューからも使う） ---
  def visible_to?(viewer)
    case visibility.to_s
    when "public"     then true
    when "private"    then viewer.present? && user_id == viewer.id
    when "followers"  then viewer.present? && (user_id == viewer.id || viewer.follows?(user))
    else false
    end
  end

  # 所有者かどうか（Policy からの利用を想定）
  def owned_by?(viewer)
    viewer.present? && user_id == viewer.id
  end

  # （任意）このログに user がコメント可能かの簡易判定
  def commentable_by?(user)
    return false if user.blank?
    visible_to?(user)
  end

  # カテゴリ（study? が他と衝突しないよう prefix）
  enum category: {
    study: 0,
    work: 1,
    exercise: 2,
    rest: 3
  }, _prefix: true
  # => log.category_study?, log.category_work? ...

  # 公開範囲
  enum visibility: {
    public: 0,
    followers: 1,
    private: 2
  }, _prefix: true
  # => log.visibility_public?, log.visibility_followers?, log.visibility_private?

  VALID_MINUTES = [15, 30, 45, 60].freeze

  validates :minutes, presence: true,
                      numericality: { only_integer: true },
                      inclusion: { in: VALID_MINUTES }
  validates :category, :visibility, presence: true
  # memo は任意

  # 日付・週の範囲で抽出
  scope :on_day,    ->(date) { where(created_at: date.in_time_zone.all_day) }
  scope :this_week, -> { where(created_at: Time.zone.now.all_week) }

  # タイムライン用
  scope :recent, -> { order(created_at: :desc) }

  # viewer に応じた可視ログ（全体タブ）
  scope :visible_to, ->(viewer) do
    if viewer.nil?
      where(visibility: visibilities[:public])
    else
      where(
        arel_table[:visibility].eq(visibilities[:public])
          .or(arel_table[:user_id].eq(viewer.id)) # 自分のログは常に見える
          .or(
            arel_table[:visibility].eq(visibilities[:followers])
              .and(arel_table[:user_id].in(viewer.following_ids))
          )
      )
    end
  end

  # Pundit::Scope から呼び出しやすい別名（中身は visible_to）
  def self.policy_scope_for(viewer)
    visible_to(viewer)
  end

  # フォロー中タブ（フォロー相手の public/followers）
  scope :timeline_for_following, ->(viewer) do
    ids = Array(viewer&.following_ids)
    if ids.empty?
      none
    else
      where(user_id: ids, visibility: [visibilities[:public], visibilities[:followers]])
    end
  end  # ← スコープの end が必要

  # === 月次抽出（ダッシュボード用） ===
  scope :for_month, ->(date = Time.zone.today) {
    where(created_at: date.beginning_of_month..date.end_of_month)
  }

  # 表示ラベル（I18nが未整備でも日本語表示できるよう暫定のマップ）
  CATEGORY_LABELS = {
    "study"    => "学習",
    "work"     => "仕事",
    "exercise" => "運動",
    "rest"     => "休憩"
  }.freeze

  # 当月カテゴリ別の合計分数（pie_chart に渡せる形）
  # 例) { "学習" => 120, "仕事" => 90, ... }
  def self.sum_minutes_by_category_for_month(date = Time.zone.today)
    raw   = for_month(date).group(:category).sum(:minutes)      # {0=>120, 1=>90, ...}
    keyed = raw.transform_keys { |v| categories.key(v) }        # {"study"=>120, "work"=>90, ...}

    keyed.transform_keys do |k|
      CATEGORY_LABELS[k.to_s] ||
        (defined?(I18n) ? I18n.t("enums.log.category.#{k}", default: nil) : nil) ||
        k.to_s.humanize
    end
  end
end
