# frozen_string_literal: true

class AddStoreFlagToTraces < ActiveRecord::Migration[5.1]
  def change
    add_column :traces, :store, :boolean, null: false, default: false
  end
end
