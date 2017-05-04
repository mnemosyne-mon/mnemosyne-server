# frozen_string_literal: true

class AddUniquenessToPlatforms < ActiveRecord::Migration[5.0]
  def change
    remove_index :platforms, :name
    add_index :platforms, :name, unique: true
  end
end
