# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities, id: :uuid do |t|
      t.timestamps null: false
    end
  end
end
