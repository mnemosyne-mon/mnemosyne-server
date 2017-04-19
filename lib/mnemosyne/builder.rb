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
      activity = ::Activity.fetch payload.fetch(:transaction)
      application = ::Application.fetch payload.fetch(:application)

      ActiveRecord::Base.transaction do
        trace ||= begin
          ::Trace.create! \
            id: payload[:uuid],
            origin_id: payload[:origin],
            application: application,
            activity: activity,
            name: payload[:name],
            start: Integer(payload[:start]),
            stop: Integer(payload[:stop]),
            meta: payload[:meta]
        end

        Array(payload[:span]).each do |span|
          ::Span.create! \
            id: span[:uuid],
            name: span[:name],
            trace: trace,
            start: Integer(span[:start]),
            stop: Integer(span[:stop]),
            meta: span[:meta]
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
