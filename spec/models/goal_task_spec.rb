# frozen_string_literal: true
require "rails_helper"

RSpec.describe GoalTask, type: :model do
  describe "associations" do
    it { should belong_to(:goal) }
    # user を必須にしていない想定。必須なら `it { should belong_to(:user) }` に変更
  end

  describe "position の自動採番" do
    it "position を指定しなければ末尾に自動採番される" do
      goal = create(:goal)
      t1 = GoalTask.create!(goal:, title: "t1") # position: 0
      t2 = GoalTask.create!(goal:, title: "t2") # position: 1
      expect([t1.position, t2.position]).to eq [0, 1]
    end

    it "position を明示指定した場合はその値を維持する" do
      goal = create(:goal)
      t = GoalTask.create!(goal:, title: "manual", position: 7)
      expect(t.position).to eq 7
    end
  end

  describe "並び順（default_scope）" do
    it "position ASC → 未設定は最後尾扱い → created_at ASC で並ぶ" do
      goal = create(:goal)
      a = GoalTask.create!(goal:, title: "a", position: 0)
      sleep 0.01
      b = GoalTask.create!(goal:, title: "b", position: 2)
      sleep 0.01
      c = GoalTask.create!(goal:, title: "c")          # position: 3（自動）
      sleep 0.01
      d = GoalTask.create!(goal:, title: "d", position: 1)

      expect(goal.goal_tasks.pluck(:title)).to eq %w[a d b c]
    end
  end
end
