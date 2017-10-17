# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

namespace :mnemosyne do
  desc 'Clean up old traces and spans'
  task clean: :environment do
    logger = Rails.logger
    logger.level = :info

    next if Platform.all.empty?

    max    = ActiveSupport::Duration.parse(Platform.maximum(:retention_period))
    cutoff = Server::Clock.to_tick(Time.zone.now - max)

    logger.info do
      "Dropping chunks older then #{Server::Clock.to_time(cutoff)}..."
    end

    ActiveRecord::Base.connection.execute <<~SQL
      SELECT drop_chunks(#{cutoff}, 'traces', NULL);
      SELECT drop_chunks(#{cutoff}, 'spans', NULL);
      SELECT drop_chunks(#{cutoff}, 'failures', NULL);
    SQL

    logger.info do
      "Dropping chunks older then #{Server::Clock.to_time(cutoff)}... [DONE]"
    end

    ActiveRecord::Base.connection.disconnect!
    ActiveRecord::Base.establish_connection

    logger.info { 'Deleting unreferenced activities...' }

    ActiveRecord::Base.connection.execute <<~SQL
      DELETE FROM activities
      WHERE NOT EXISTS(
        SELECT 1
        FROM traces
        WHERE activity_id = activities.id
      );
    SQL

    logger.info { 'Deleting unreferenced activities... [DONE]' }
  end
end
