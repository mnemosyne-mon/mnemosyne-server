# frozen_string_literal: true

class AddIdIndexOnTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, :id
  end
end
