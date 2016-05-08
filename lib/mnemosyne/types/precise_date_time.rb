module Mnemosyne
  module Types
    class PreciseDateTime < ActiveRecord::Type::Value
      def type_cast_for_database(value)
        return super unless value.acts_like?(:time)

        value = value.getutc

        ::Mnemosyne::Clock.to_tick value
      end

      def type_cast_from_database(value)
        return unless value

        ::Mnemosyne::Clock.to_time value
      end

      def klass
        nil
      end

      def type
        nil
      end

      def cast_value(value)
        if value.is_a?(Fixnum)
          ::Mnemosyne::Clock.to_time value
        elsif value.is_a?(String) && value =~ /^\d+$/
          ::Mnemosyne::Clock.to_time Integer(value)
        else
          super
        end
      end
    end
  end
end
