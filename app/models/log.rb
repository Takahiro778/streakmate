class Log < ApplicationRecord
  belongs_to :user

  # 将来の分析のため category は enum（必要に応じて増減OK）
  enum category: {
    study: 0,
    work: 1,
    exercise: 2,
    rest: 3
  }

  # minutes は数値、15/30/45/60のクイックボタン前提（必要なら許容値を拡張）
  VALID_MINUTES = [15, 30, 45, 60].freeze

  validates :minutes, presence: true, numericality: { only_integer: true }, inclusion: { in: VALID_MINUTES }
  validates :category, presence: true
  # memo は任意
end
