# frozen_string_literal: true

module Mnemosyne
  module Clock
    class << self
      def to_tick(time)
        utc = time.utc
        utc.to_i * 1_000_000_000 + utc.nsec
      end

      def to_time(value)
        Time.at(Rational(value.to_i, 1_000_000_000)).utc.localtime
      end
    end
  end
end
