# frozen_string_literal: true

class AddUniquenessIndexOnActivities < ActiveRecord::Migration[5.1]
  def change
    add_index :activities, %i[platform_id id], unique: true
  end
end
