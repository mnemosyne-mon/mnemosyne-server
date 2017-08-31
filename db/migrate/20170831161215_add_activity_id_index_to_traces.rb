# frozen_string_literal: true

class AddActivityIdIndexToTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, %i[activity_id]
  end
end
