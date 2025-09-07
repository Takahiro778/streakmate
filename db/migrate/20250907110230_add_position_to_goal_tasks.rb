class AddPositionToGoalTasks < ActiveRecord::Migration[7.1]
  def up
    # 1) カラム/インデックスが無いときだけ追加
    add_column :goal_tasks, :position, :integer unless column_exists?(:goal_tasks, :position)
    add_index  :goal_tasks, [:goal_id, :position] unless index_exists?(:goal_tasks, [:goal_id, :position])

    # 2) 既存データのうち position が NULL の行だけ安全に採番
    say_with_time "Backfilling goal_tasks.position (only where NULL)" do
      GoalTask.reset_column_information

      # ← 主キー不要にするため pluck で goal_id 一覧を取得（find_eachは使わない）
      goal_ids = GoalTask.where(position: nil).distinct.pluck(:goal_id)

      goal_ids.each do |gid|
        # 既にpositionが埋まっている行がある場合に備えて基準位置を取得
        base = GoalTask.where(goal_id: gid).where.not(position: nil).maximum(:position) || -1

        ids = GoalTask.where(goal_id: gid, position: nil)
                      .order(:created_at, :id)
                      .pluck(:id)

        ids.each_with_index do |id, i|
          GoalTask.where(id: id).update_all(position: base + i + 1)
        end
      end
    end
  end

  def down
    remove_index  :goal_tasks, [:goal_id, :position] if index_exists?(:goal_tasks, [:goal_id, :position])
    remove_column :goal_tasks, :position             if column_exists?(:goal_tasks, :position)
  end
end
