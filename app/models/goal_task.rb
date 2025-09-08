# frozen_string_literal: true

# 既存の GoalTask を拡張し、「完了系の共通API」を必ず提供する
class GoalTask < ApplicationRecord
  # === 完了判定（スキーマに合わせて自動判定） ===
  def completed?
    if has_attribute?(:completed)            # boolean
      !!self[:completed]
    elsif has_attribute?(:completed_at)      # datetime
      self[:completed_at].present?
    elsif has_attribute?(:status)            # enum/string
      done_words = %w[done completed finished]
      done_words.include?(self[:status].to_s)
    else
      false
    end
  end

  # === 完了化 ===
  def complete!
    if has_attribute?(:completed)            # boolean
      update!(completed: true)
    elsif has_attribute?(:completed_at)      # datetime
      update!(completed_at: Time.current)
    elsif has_attribute?(:status)            # enum/string/enum(status:)
      update!(status: pick_done_status_value)
    else
      touch # どうしても無い場合の保険（UI同期）
    end
  end

  # === 未完了へ戻す ===
  def reopen!
    if has_attribute?(:completed)            # boolean
      update!(completed: false)
    elsif has_attribute?(:completed_at)      # datetime
      update!(completed_at: nil)
    elsif has_attribute?(:status)            # enum/string/enum(status:)
      update!(status: pick_open_status_value)
    else
      touch
    end
  end

  private

  # enum を使っていてもいなくても安全に値を選ぶ
  def pick_done_status_value
    # enum 定義がある場合は defined_enums を見て、なければ文字列 "completed"
    enums = self.class.defined_enums || {}
    if enums.key?("status")
      # enum に done/completed/finished のいずれかがあればそれを使う
      %w[done completed finished].find { |k| enums["status"].key?(k) }&.to_sym || :completed
    else
      "completed"
    end
  end

  def pick_open_status_value
    enums = self.class.defined_enums || {}
    if enums.key?("status")
      %w[open todo pending].find { |k| enums["status"].key?(k) }&.to_sym || :open
    else
      "open"
    end
  end
end
