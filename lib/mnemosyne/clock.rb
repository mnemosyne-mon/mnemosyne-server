# frozen_string_literal: true

module Mnemosyne
  module Clock
    class << self
      def to_tick(time)
        utc = time.utc
        utc.to_i * 1_000_000_000 + utc.nsec
      end

      def to_time(value)
        time = Time.at(0).utc + Rational(value.to_i, 1_000_000_000)
        time.localtime
      end
    end
  end
end
