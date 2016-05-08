module Mnemosyne
  module Types
    class PreciseDateTime < ActiveRecord::Type::DateTime
      def type_cast_for_database(value)
        if (time = type_cast(value))
          time.to_i * 1_000_000_000 + time.nsec
        else
          nil
        end
      end

      def type_cast_from_database(value)
        return unless value

        time = Time.at 0
        time = time + Rational(value.to_i, 1_000_000_000)
        time
      end
    end
  end
end
