# frozen_string_literal: true

class AddHostnameToTraces < ActiveRecord::Migration[5.1]
  def up
    add_column :traces, :hostname, :string
    change_column_null :traces, :hostname, false, 'unknown'

    add_index :traces, :hostname
  end

  def down
    remove_index :traces, :hostname
    remove_column :traces, :hostname
  end
end
