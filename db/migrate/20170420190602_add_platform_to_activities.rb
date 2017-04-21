# frozen_string_literal: true

class AddPlatformToActivities < ActiveRecord::Migration[5.0]
  class Platform < ActiveRecord::Base
    def self.default
      find_or_create_by name: 'default'
    end
  end

  class Activity < ActiveRecord::Base
  end

  def up
    add_column :activities, :platform_id, :uuid, null: true

    if Activity.any?
      # rubocop:disable Rails/SkipsModelValidations
      Activity.where(platform_id: nil).update_all \
        platform_id: Platform.default.id
    end

    change_column :activities, :platform_id, :uuid, null: false
  end

  def down
    remove_column :activities, :platform_id
  end
end
