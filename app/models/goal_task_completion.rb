# frozen_string_literal: true

# 既存の GoalTask を再オープンして「完了系の共通API」を必ず提供する
class GoalTask < ApplicationRecord
  # === 完了判定（スキーマに合わせて自動判定） ===
  def completed?
    if self.has_attribute?(:completed)      # boolean
      !!self[:completed]
    elsif self.has_attribute?(:completed_at) # datetime
      self[:completed_at].present?
    elsif self.has_attribute?(:status)       # enum/string
      self[:status].to_s.in?(%w[done completed])
    else
      false
    end
  end

  # === 完了化 ===
  def complete!
    if self.has_attribute?(:completed)      # boolean
      update!(completed: true)
    elsif self.has_attribute?(:completed_at) # datetime
      update!(completed_at: Time.current)
    elsif self.has_attribute?(:status)       # enum/string
      # enum を使っていて :completed が未定義でも文字列なら更新可
      update!(status: (self.statuses&.key?("completed") ? :completed : "completed"))
    else
      touch # どうしても無い場合の保険（UI同期）
    end
  end

  # === 未完了へ戻す ===
  def reopen!
    if self.has_attribute?(:completed)      # boolean
      update!(completed: false)
    elsif self.has_attribute?(:completed_at) # datetime
      update!(completed_at: nil)
    elsif self.has_attribute?(:status)       # enum/string
      update!(status: (self.statuses&.key?("open") ? :open : "open"))
    else
      touch
    end
  end
end
