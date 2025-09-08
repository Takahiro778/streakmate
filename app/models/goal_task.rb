# frozen_string_literal: true

class GoalTask < ApplicationRecord
  belongs_to :goal, optional: false

  # === 完了系スコープ（スキーマに依存せず自動判定） ===
  class << self
    def incomplete
      if column_exists?(:completed)           # boolean
        where(completed: [false, nil])
      elsif column_exists?(:completed_at)     # datetime
        where(completed_at: nil)
      elsif column_exists?(:status)           # enum/string
        # done/completed/finished を完了扱い。それ以外 or NULL を未完とみなす
        where.not(status: done_words).or(where(status: [nil, "open", "todo", "pending"]))
      else
        all
      end
    end

    def completed
      if column_exists?(:completed)           # boolean
        where(completed: true)
      elsif column_exists?(:completed_at)     # datetime
        where.not(completed_at: nil)
      elsif column_exists?(:status)           # enum/string
        where(status: done_words)
      else
        none
      end
    end

    # 並び順（position → id）。position が NULL は末尾へ
    def ordered
      if column_exists?(:position)
        order(Arel.sql("COALESCE(position, 2147483647) ASC"), :id)
      else
        order(:id)
      end
    end

    private

    def column_exists?(name)
      column_names.include?(name.to_s)
    end

    def done_words
      %w[done completed finished]
    end
  end

  # === 完了判定（インスタンス） ===
  def completed?
    if has_attribute?(:completed)            # boolean
      !!self[:completed]
    elsif has_attribute?(:completed_at)      # datetime
      self[:completed_at].present?
    elsif has_attribute?(:status)            # enum/string
      %w[done completed finished].include?(self[:status].to_s)
    else
      false
    end
  end

  # === 完了化 ===
  def complete!
    if has_attribute?(:completed)
      update!(completed: true)
    elsif has_attribute?(:completed_at)
      update!(completed_at: Time.current)
    elsif has_attribute?(:status)
      update!(status: pick_done_status_value)
    else
      touch
    end
  end

  # === 未完了へ戻す ===
  def reopen!
    if has_attribute?(:completed)
      update!(completed: false)
    elsif has_attribute?(:completed_at)
      update!(completed_at: nil)
    elsif has_attribute?(:status)
      update!(status: pick_open_status_value)
    else
      touch
    end
  end

  private

  # enum を使っていてもいなくても安全に値を選ぶ
  def pick_done_status_value
    enums = self.class.defined_enums || {}
    if enums.key?("status")
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
