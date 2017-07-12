# frozen_string_literal: true

module Server
  module Types
    class PreciseDateTime < ActiveRecord::Type::Value
      def serialize(value)
        ::Server::Clock.to_tick(value)
      end

      def cast(value)
        if value.is_a?(Integer)
          ::Server::Clock.to_time value
        elsif value.is_a?(String) && value =~ /^\d+$/
          ::Server::Clock.to_time Integer(value)
        elsif value.acts_like?(:time)
          value
        end
      end
    end
  end
end
