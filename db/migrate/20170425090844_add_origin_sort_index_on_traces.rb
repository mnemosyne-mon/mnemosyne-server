# frozen_string_literal: true

class AddOriginSortIndexOnTraces < ActiveRecord::Migration[5.0]
  def change
    add_index :traces, %i[origin_id start],
      name: 'index_traces_on_origin_start_desc',
      where: 'origin_id IS NULL',
      order: {start: :desc},
      using: :btree
  end
end
