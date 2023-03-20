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

    sql = ActiveRecord::Base.sanitize_sql([<<~SQL.squish, {interval: retention.iso8601}])
      SELECT drop_chunks('traces', older_than => interval :interval);
      SELECT drop_chunks('spans', older_than => interval :interval);
      SELECT drop_chunks('failures', older_than => interval :interval);
    SQL

    ActiveRecord::Base.connection.execute(sql)

    logger.info do
      "Dropping chunks older then #{cutoff}... [DONE]"
    end
  end
end
