# frozen_string_literal: true

class AddUniquenessToApplications < ActiveRecord::Migration[5.0]
  def change
    add_index :applications, %i[platform_id name], unique: true
  end
end
