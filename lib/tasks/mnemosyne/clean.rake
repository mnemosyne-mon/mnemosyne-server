# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

namespace :mnemosyne do
  desc 'Clean up old traces and spans'
  task clean: :environment do
    logger = Rails.logger
    logger.level = :info

    return if Platform.all.empty?

    max    = ActiveSupport::Duration.parse(Platform.maximum(:retention_period))
    cutoff = Server::Clock.to_tick(Time.zone.now - max)

    ActiveRecord::Base.connection.execute <<-SQL
      SELECT _timescaledb_internal.drop_chunks_older_than(#{cutoff}, 'traces', 'public');
      SELECT _timescaledb_internal.drop_chunks_older_than(#{cutoff}, 'spans', 'public');
    SQL

    logger.info do
      "Dropped chunks older then #{Server::Clock.to_time(cutoff)}..."
    end
  end
end
