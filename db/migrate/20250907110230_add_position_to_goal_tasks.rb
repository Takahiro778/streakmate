# frozen_string_literal: true

class AddPositionToGoalTasks < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! # 大量更新でもロック時間を抑えるため（必須ではない）

  # モデルに依存しない匿名クラス（default_scopeの影響を受けない）
  class MtGoalTask < ActiveRecord::Base
    self.table_name = "goal_tasks"
  end

  def up
    # 1) カラムが無ければ作成（既にある環境では何もしない）
    unless column_exists?(:goal_tasks, :position)
      add_column :goal_tasks, :position, :integer
    end

    # 2) インデックス（存在しなければ追加）
    unless index_exists?(:goal_tasks, [:goal_id, :position])
      add_index :goal_tasks, [:goal_id, :position], algorithm: :concurrently
    end

    # 3) 既存データの position を安全にバックフィル（NULLのみ）
    say "Backfilling goal_tasks.position (only where NULL)"

    # default_scope を避けるために unscoped かつ匿名クラスを使用
    # goalごとに created_at, id の順で安定ソートして連番を採番
    scope = MtGoalTask.unscoped
                      .where(position: nil)
                      .order(:goal_id, :created_at, :id)

    current_goal_id = nil
    next_pos = 0
    batch = []

    scope.find_each(batch_size: 500) do |task|
      if task.goal_id != current_goal_id
        # そのゴールの既存最大positionの続きから採番
        max_pos = MtGoalTask.unscoped
                             .where(goal_id: task.goal_id)
                             .where.not(position: nil)
                             .maximum(:position)
        next_pos = max_pos ? max_pos + 1 : 0
        current_goal_id = task.goal_id
      end

      batch << { id: task.id, position: next_pos }
      next_pos += 1

      if batch.size >= 500
        bulk_update_positions(batch)
        batch.clear
      end
    end

    bulk_update_positions(batch) if batch.any?
  end

  def down
    # 取り消しは position を削除するだけ（必要なら）
    if column_exists?(:goal_tasks, :position)
      remove_index :goal_tasks, column: [:goal_id, :position] if index_exists?(:goal_tasks, [:goal_id, :position])
      remove_column :goal_tasks, :position
    end
  end

  private

  # Postgres向けバルク更新（1回の UPDATE ... CASE 式でまとめて更新）
  def bulk_update_positions(rows)
    ids = rows.map { |r| r[:id] }
    cases = rows.map { |r| "WHEN #{r[:id]} THEN #{r[:position]}" }.join(" ")
    sql = <<~SQL
      UPDATE goal_tasks
      SET position = CASE id #{cases} END
      WHERE id IN (#{ids.join(",")})
    SQL
    MtGoalTask.connection.execute(sql)
  end
end
