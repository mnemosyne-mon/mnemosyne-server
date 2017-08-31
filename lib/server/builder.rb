# frozen_string_literal: true

module Server
  class Builder
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call(payload)
      platform = ::Platform.upsert name: payload.fetch(:platform)

      activity = ::Activity.upsert \
        id: payload.fetch(:transaction),
        platform_id: platform.id

      application = ::Application.upsert \
        name: payload.fetch(:application),
        platform_id: platform.id

      ActiveRecord::Base.transaction do
        trace ||= begin
          ::Trace.create! \
            id: payload[:uuid],
            origin_id: payload[:origin],
            application: application,
            activity: activity,
            platform: platform,
            hostname: payload[:hostname],
            name: payload[:name],
            start: Integer(payload[:start]),
            stop: Integer(payload[:stop]),
            meta: payload[:meta]
        end

        # `Span.column_names` is required to force bulk insert plugin
        # to process `id` column too.
        Span.bulk_insert(*Span.column_names) do |worker|
          Array(payload[:span]).each do |data|
            worker.add \
              id: data[:uuid],
              name: data[:name],
              trace_id: trace.id,
              platform_id: trace.platform_id,
              start: Integer(data[:start]),
              stop: Integer(data[:stop]),
              meta: data[:meta]
          end
        end
      end
    end
  end
end
