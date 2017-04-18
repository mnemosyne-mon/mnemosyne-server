# frozen_string_literal: true

class AddOriginalNameToApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :applications, :original_name, :string
  end
end
