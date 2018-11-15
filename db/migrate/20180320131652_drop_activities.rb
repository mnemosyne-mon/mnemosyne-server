# frozen_string_literal: true

class DropActivities < ActiveRecord::Migration[5.1]
  def up
    drop_table :activities
  end
end
