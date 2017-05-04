# frozen_string_literal: true

class ChangeApplications < ActiveRecord::Migration[5.0]
  def change
    rename_column :applications, :name, :title
    rename_column :applications, :original_name, :name
  end
end
