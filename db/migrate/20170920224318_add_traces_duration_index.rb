# frozen_string_literal: true

class AddTracesDurationIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, '(stop - start)', name: 'index_traces_duration'
  end
end
