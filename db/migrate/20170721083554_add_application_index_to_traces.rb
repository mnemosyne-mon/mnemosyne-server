# frozen_string_literal: true

class AddApplicationIndexToTraces < ActiveRecord::Migration[5.1]
  def change
    add_index :traces, :application_id
  end
end
