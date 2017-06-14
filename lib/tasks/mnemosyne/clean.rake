# frozen_string_literal: true

# rubocop:disable BlockLength
namespace :mnemosyne do
  desc 'Clean up old traces and spans'
  task clean: :environment do
    logger = Rails.logger
    dry    = ENV['DRY']

    logger.level = :info

    Platform.all.each do |platform|
      logger.info "==== Cleanup #{platform.name} ===="
      logger.info " [I] Retention period: #{platform.retention_period.inspect}"

      tscope = platform.traces.retention \
        platform.retention_period, Time.zone.now

      ctraces = 0
      cspans = 0

      while tscope.any?
        traces = tscope.pluck(:id)

        traces.each_slice(10_000) do |slice|
          ActiveRecord::Base.transaction do
            if dry
              ctraces += slice.size
              cspans += Span.where(trace_id: slice).count
            else
              ctraces += Trace.where(id: slice).delete_all
              cspans += Span.where(trace_id: slice).delete_all
            end
          end
        end

        tscope = [] if dry
      end

      if dry
        logger.info " --> Would delete approximately #{ctraces} traces; #{cspans} spans"
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
