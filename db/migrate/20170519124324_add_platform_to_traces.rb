# frozen_string_literal: true

class AddPlatformToTraces < ActiveRecord::Migration[5.1]
  def up
    add_column :traces, :platform_id, :uuid, null: true

    execute <<-SQL
      UPDATE traces
      SET platform_id = (
        SELECT platform_id
        FROM activities
        WHERE activities.id = traces.activity_id
      )
    SQL

    change_column :traces, :platform_id, :uuid, null: false
  end

  def down
    remove_column :traces, :platform_id
  end
end
