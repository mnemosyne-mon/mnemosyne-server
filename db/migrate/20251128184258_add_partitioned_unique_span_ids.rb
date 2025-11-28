# frozen_string_literal: true

class AddPartitionedUniqueSpanIds < ActiveRecord::Migration[8.1]
  def change
    remove_index :spans, :id
    add_index :spans, :id, unique: true
  end
end
