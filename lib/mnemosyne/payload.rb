# frozen_string_literal: true

module Mnemosyne
  module Payload
    class << self
      def new(payload, version: nil, **kwargs)
        version ||= payload.fetch(:version, 1)

        case version
          when 1
            ::Mnemosyne::Payload::V1.new(payload, **kwargs)
          else
            raise "Invalid payload version: #{version}"
        end
      end
    end

    ::Dry::Types.register 'uuid',
      Dry::Types::Definition.new(UUID4).constructor(UUID4.method(:try_convert))

    ::Dry::Types.register 'strict.uuid',
      ::Dry::Types['uuid'].constrained(type: UUID4)

    module Types
      Name = ::Dry::Types['coercible.string']
      UUID = ::Dry::Types['strict.uuid']
    end

    class V1 < ::Dry::Struct::Value
      attribute :application, Types::Name
      attribute :activity, Types::UUID
      attribute :platform, Types::Name

      attr_reader :trace
      attr_reader :spans

      def initalize(payload)
        @application = Types::Name[payload[:application]]
        @activity = Types::UUID[payload[:activity]]
        @platform = Types::Name[payload[:platform]]

        @trace = payload.slice(:uuid, :origin, :name, :start, :stop, :meta)
        @spans = Array(payload[:span]).map do |h|
          h.slice(:uuid, :name, :start, :stop, :meta)
        end
      end
    end
  end
end
