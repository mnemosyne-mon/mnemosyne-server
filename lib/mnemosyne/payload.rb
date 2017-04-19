# frozen_string_literal: true

module Mnemosyne
  module Payload
    class << self
      def new(payload, version: nil)
        version ||= payload.fetch(:version, 1)

        case version
          when 1
            ::Mnemosyne::Payload::V1.new(payload)
          else
            raise "Invalid payload version: #{version}"
        end
      end
    end

    module Types
      Name = ::Dry::Types::Definition.new(String)
        .constructor do |input|
          String(input).strip.tap do |str|
            raise TypeError.new 'Must not be blank' if str.blank?
          end
        end

      UUID = ::Dry::Types::Definition.new(UUID4)
        .constructor do |input|
          UUID4.try_convert(input) ||
            (raise TypeError.new "Invalid UUID: #{input.inspect}")
        end

      NanoTime = ::Dry::Types::Definition.new(Time)
        .constructor {|ts| ::Mnemosyne::Clock.to_time(ts) }

      Meta = ::Dry::Types['hash']
    end

    class V1 < ::Dry::Struct::Value
      class Span < ::Dry::Struct::Value
        constructor_type :strict_with_defaults

        attribute :uuid, Types::UUID
        attribute :name, Types::Name
        attribute :start, Types::NanoTime
        attribute :stop, Types::NanoTime
        attribute :meta, Types::Meta.optional.default({})
      end

      attr_reader :trace
      attr_reader :spans

      constructor_type :strict_with_defaults

      attribute :application, Types::Name
      attribute :platform, Types::Name
      attribute :activity, Types::UUID

      attribute :uuid, Types::UUID
      attribute :origin, Types::UUID.optional.default(nil)
      attribute :name, Types::Name
      attribute :start, Types::NanoTime
      attribute :stop, Types::NanoTime
      attribute :meta, Types::Meta.optional.default({})

      attribute :span, ::Dry::Types['array'].member(Span).default([])
    end
  end
end
