# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

namespace :mnemosyne do
  desc 'Clean up old traces and spans'
  task clean: :environment do
    require 'server/clock'

    logger = Rails.logger
    logger.level = :info

    next if Platform.all.empty?

    max    = ActiveSupport::Duration.parse(Platform.maximum(:retention_period))
    cutoff = Server::Clock.to_tick(Time.zone.now - max)

    logger.info do
      "Dropping chunks older then #{Server::Clock.to_time(cutoff)}..."
    end

    ActiveRecord::Base.connection.execute <<~SQL
      SELECT drop_chunks(#{cutoff}, 'traces');
      SELECT drop_chunks(#{cutoff}, 'spans');
      SELECT drop_chunks(#{cutoff}, 'failures');
    SQL

    logger.info do
      "Dropping chunks older then #{Server::Clock.to_time(cutoff)}... [DONE]"
    end
  end
end
