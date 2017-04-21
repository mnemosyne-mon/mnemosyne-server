# frozen_string_literal: true

class AddPlatformToApplication < ActiveRecord::Migration[5.0]
  class Platform < ActiveRecord::Base
    def self.default
      find_or_create_by name: 'default'
    end
  end

  class Application < ActiveRecord::Base
  end

  def up
    add_column :applications, :platform_id, :uuid, null: true

    if Application.any?
      # rubocop:disable Rails/SkipsModelValidations
      Application.where(platform_id: nil).update_all \
        platform_id: Platform.default.id
    end

    change_column :applications, :platform_id, :uuid, null: false
  end

  def down
    remove_column :applications, :platform_id
  end
end
