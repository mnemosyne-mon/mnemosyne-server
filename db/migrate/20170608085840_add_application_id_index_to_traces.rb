# frozen_string_literal: true

class AddApplicationIdIndexToTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, :application_id
  end
end
