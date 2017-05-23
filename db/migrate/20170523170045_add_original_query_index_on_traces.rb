# frozen_string_literal: true

class AddOriginalQueryIndexOnTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, %i[platform_id origin_id stop],
      where: '(origin_id IS NULL)',
      order: {stop: :desc},
      name: 'index_traces_platform_original_stop_ordered'

    add_index :traces, %i[platform_id stop],
      order: {stop: :desc},
      name: 'index_traces_platform_stop_ordered'
  end
end
