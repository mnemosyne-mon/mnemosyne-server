# frozen_string_literal: true

require "server/clock"

module Server
  class Builder
    def call(payload)
      platform = ::Platform.fetch name: payload.fetch(:platform)

      application = ::Application.fetch \
        name: payload.fetch(:application),
        platform: platform.id

      trace ||= begin
        ::Trace.create!(
          id: payload[:uuid],
          meta: payload[:meta],
          name: payload[:name],
          platform:,
          hostname: payload[:hostname],
          application:,
          origin_id: payload[:origin],
          activity_id: payload[:transaction],
          start: ::Server::Clock.to_time(Integer(payload[:start])),
          stop: ::Server::Clock.to_time(Integer(payload[:stop])),
        )
      end

      spans = [{
        id: payload[:uuid],
        meta: payload[:meta],
        name: payload[:name],
        trace_id: trace.id,
        platform_id: trace.platform_id,
        start: ::Server::Clock.to_time(Integer(payload[:start])),
        stop: ::Server::Clock.to_time(Integer(payload[:stop])),
      }]

      Array.wrap(payload[:span]).each do |data|
        spans.append({
          id: data[:uuid],
          meta: data[:meta],
          name: data[:name],
          trace_id: trace.id,
          platform_id: trace.platform_id,
          start: ::Server::Clock.to_time(Integer(data[:start])),
          stop: ::Server::Clock.to_time(Integer(data[:stop])),
        })
      end

      Span.upsert_all(spans, unique_by: :id) # rubocop:disable Rails/SkipsModelValidations

      payload.fetch(:errors, []).each do |error|
        Failure.create! \
          type: error.fetch(:type),
          text: error.fetch(:text),
          stop: trace.stop,
          trace:,
          hostname: trace.hostname,
          platform: trace.platform,
          application: trace.application,
          stacktrace: error.fetch(:stacktrace, [])
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
