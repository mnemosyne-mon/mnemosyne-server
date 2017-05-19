# frozen_string_literal: true

class AddPlatformToTraces < ActiveRecord::Migration[5.1]
  class Platform < ActiveRecord::Base
    def self.default
      find_or_create_by name: 'default'
    end
  end

  class Application < ActiveRecord::Base
  end

  class Activity < ActiveRecord::Base
    has_many :traces
    belongs_to :platform
  end

  def up
    add_column :traces, :platform_id, :uuid, null: true

    execute <<-SQL
      UPDATE traces
      SET platform_id = (
        SELECT platform_id
        FROM activities
        WHERE activities.id = traces.activity_id
      )
    SQL

    change_column :traces, :platform_id, :uuid, null: false
  end

  def down
    remove_column :traces, :platform_id
  end
end
