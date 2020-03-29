# frozen_string_literal: true

require 'server/clock'

module Server
  class Builder
    # rubocop:disable AbcSize
    # rubocop:disable MethodLength
    # rubocop:disable BlockLength
    def call(payload)
      platform = ::Platform.fetch name: payload.fetch(:platform)

      application = ::Application.fetch \
        name: payload.fetch(:application),
        platform: platform.id

      trace ||= begin
        ::Trace.create! \
          id: payload[:uuid],
          origin_id: payload[:origin],
          application: application,
          activity_id: payload[:transaction],
          platform: platform,
          hostname: payload[:hostname],
          name: payload[:name],
          start: ::Server::Clock.to_time(Integer(payload[:start])),
          stop: ::Server::Clock.to_time(Integer(payload[:stop])),
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
            start: ::Server::Clock.to_time(Integer(data[:start])),
            stop: ::Server::Clock.to_time(Integer(data[:stop])),
            meta: data[:meta]
        end
      end

      payload.fetch(:errors, []).each do |error|
        Failure.create! \
          type: error.fetch(:type),
          text: error.fetch(:text),
          stop: trace.stop,
          trace: trace,
          hostname: trace.hostname,
          platform: trace.platform,
          application: trace.application,
          stacktrace: error.fetch(:stacktrace, [])
      end
    end
  end
end
