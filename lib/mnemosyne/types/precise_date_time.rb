# frozen_string_literal: true
module Mnemosyne
  module Types
    class PreciseDateTime < ActiveRecord::Type::Value
      def serialize(value)
        ::Mnemosyne::Clock.to_tick(value)
      end

      def cast(value)
        if value.is_a?(Integer)
          ::Mnemosyne::Clock.to_time value
        elsif value.is_a?(String) && value =~ /^\d+$/
          ::Mnemosyne::Clock.to_time Integer(value)
        elsif value.acts_like?(:time)
          value.getutc
        end
      end
    end
  end
end
