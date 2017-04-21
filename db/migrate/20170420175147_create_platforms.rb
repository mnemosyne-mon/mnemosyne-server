# frozen_string_literal: true

class CreatePlatforms < ActiveRecord::Migration[5.0]
  def change
    create_table :platforms, id: :uuid do |t|
      t.string :name
      t.string :title

      t.timestamps
    end

    add_index :platforms, :name
  end
end
