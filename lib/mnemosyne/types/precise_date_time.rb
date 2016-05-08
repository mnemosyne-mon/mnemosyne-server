module Mnemosyne
  module Types
    class PreciseDateTime < ActiveRecord::Type::DateTime
      def type_cast_for_database(value)
        if (time = type_cast(value))
          ::Mnemosyne::Clock.to_tick time
        else
          nil
        end
      end

      def type_cast_from_database(value)
        return unless value

        ::Mnemosyne::Clock.to_time value
      end
    end
  end
end
