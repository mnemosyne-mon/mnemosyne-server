# frozen_string_literal: true

class AddIdIndexOnSpans < ActiveRecord::Migration[5.1]
  def change
    add_index :spans, :id
  end
end
