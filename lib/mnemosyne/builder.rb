# frozen_string_literal: true

module Mnemosyne
  class Builder
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create!
      platform = ::Platform.acquire payload.fetch(:platform)
      activity = platform.activities.fetch payload.fetch(:transaction)
      application = platform.applications.fetch payload.fetch(:application)

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
              start: Integer(data[:start]),
              stop: Integer(data[:stop]),
              meta: data[:meta]
          end
        end
      end
    end

    class << self
      def create!(payload)
        new(payload).create!
      end
    end
  end
end
