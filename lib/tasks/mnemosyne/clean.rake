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

    retention = Platform.maximum(:retention_period)
    cutoff = Time.zone.now - retention

    logger.info do
      "Dropping chunks older then #{cutoff}..."
    end

    sql = ActiveRecord::Base.sanitize_sql([<<~SQL.squish, {interval: retention}])
      SELECT drop_chunks(interval :interval, 'traces');
      SELECT drop_chunks(interval :interval, 'spans');
      SELECT drop_chunks(interval :interval, 'failures');
    SQL

    ActiveRecord::Base.connection.execute(sql)

    logger.info do
      "Dropping chunks older then #{cutoff}... [DONE]"
    end
  end
end
