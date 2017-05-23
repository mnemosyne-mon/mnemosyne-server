# frozen_string_literal: true

class AddOrderIndexToTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, :platform_id
    add_index :traces, %i[platform_id created_at]
  end
end
