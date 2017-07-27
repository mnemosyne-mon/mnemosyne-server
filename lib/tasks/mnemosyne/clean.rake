# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

# rubocop:disable BlockLength
namespace :mnemosyne do
  desc 'Clean up old traces and spans'
  task clean: :environment do
    logger = Rails.logger
    dry    = ENV['DRY']

    logger.level = :info

    time = Time.zone.now

    Platform.all.each do |platform|
      logger.info "==== Cleanup #{platform.name} ===="
      logger.info " [I] Retention period: #{platform.retention_period.inspect}"

      ctraces = 0
      cspans = 0

      ActiveRecord::Base.transaction do
        traces = platform
          .traces
          .retention(platform.retention_period, time)

        spans = Span
          .retention(platform.retention_period, time)
          .where(trace_id: traces.select(:id))

        # Spans *must* be deleted before traces as condition clauses will
        # otherwise not match anything anymore and all spans will be left
        # dangling.

        if dry
          cspans = spans.count
          ctraces = traces.count
        else
          cspans = spans.delete_all
          ctraces = traces.delete_all
        end
      end

      if dry
        logger.info \
          " --> Would delete approximately #{ctraces} traces; #{cspans} spans"
      else
        logger.info " --> Deleted #{ctraces} traces; #{cspans} spans"
      end
    end

    logger.info '==== VACUUM ANALYSE ===='

    if dry
      logger.info ' --> Would vacuum traces'
    else
      ActiveRecord::Base.connection.execute <<-SQL
        VACUUM ANALYSE traces;
      SQL

      logger.info ' --> Vacuumed traces'
    end

    if dry
      logger.info ' --> Would vacuum spans'
    else
      ActiveRecord::Base.connection.execute <<-SQL
        VACUUM ANALYSE spans;
      SQL

      logger.info ' --> Vacuumed spans'
    end

    logger.info ' ==== DONE ===='
  end
end
