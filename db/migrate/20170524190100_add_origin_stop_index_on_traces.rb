# frozen_string_literal: true

class AddOriginStopIndexOnTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, %i[origin_id stop],
      name: 'index_traces_on_origin_stop_desc',
      where: 'origin_id IS NULL',
      order: {stop: :desc},
      using: :btree
  end
end
