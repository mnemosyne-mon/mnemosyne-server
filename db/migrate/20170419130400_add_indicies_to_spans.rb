# frozen_string_literal: true

class AddIndiciesToSpans < ActiveRecord::Migration[5.0]
  def change
    add_index :spans, :name
    add_index :spans, :trace_id
    add_index :spans, :start
  end
end
