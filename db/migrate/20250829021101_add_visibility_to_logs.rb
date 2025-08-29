class AddVisibilityToLogs < ActiveRecord::Migration[7.1]
  def change
    # 公開範囲を表すカラム（enum :visibility 用）
    add_column :logs, :visibility, :integer, null: false, default: 0

    # visibility にだけインデックスを追加（他は重複しているので不要）
    add_index :logs, :visibility
  end
end
