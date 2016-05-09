class AddOriginalNameToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :original_name, :string
  end
end
