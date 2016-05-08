class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications, id: :uuid do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
