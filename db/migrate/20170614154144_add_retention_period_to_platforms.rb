# frozen_string_literal: true

class AddRetentionPeriodToPlatforms < ActiveRecord::Migration[5.1]
  def change
    add_column :platforms, :retention_period, :interval, default: '30 days'
  end
end
