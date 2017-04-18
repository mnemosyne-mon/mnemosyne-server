# frozen_string_literal: true

module Mnemosyne
  module Clock
    class << self
      def to_tick(time)
        time.to_i * 1_000_000_000 + time.nsec
      end

      def to_time(value)
        Time.at(0) + Rational(value.to_i, 1_000_000_000)
      end
    end
  end
end
