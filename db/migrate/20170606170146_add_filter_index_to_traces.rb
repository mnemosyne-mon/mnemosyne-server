# frozen_string_literal: true

class AddFilterIndexToTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, :meta,
      using: :gin,
      name: 'index_traces_filter_meta'
    add_index :traces, "(meta->>'method')",
      name: 'index_traces_filter_meta_method'
  end
end
