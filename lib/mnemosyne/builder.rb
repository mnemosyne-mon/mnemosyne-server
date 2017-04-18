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
      ActiveRecord::Base.transaction do
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

    def application
      @application ||= ::Application.fetch payload.fetch(:application)
    end

    def activity
      @activity ||= ::Activity.fetch payload.fetch(:transaction)
    end

    def trace
      @trace ||= begin
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
    end

    class << self
      def create!(payload)
        new(payload).create!
      end
    end
  end
end
