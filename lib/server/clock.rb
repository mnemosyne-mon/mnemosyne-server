# frozen_string_literal: true

module Server
  module Clock
    class << self
      def to_tick(time)
        if time.is_a?(::ActiveSupport::Duration)
          (time.to_f * 1_000_000_000).to_i
        else
          utc = time.utc
          utc.to_i * 1_000_000_000 + utc.nsec
        end
      end

      def to_time(ticks)
        Time.at(to_seconds(ticks)).utc.localtime
      end

      def to_duration(ticks)
        ::ActiveSupport::Duration.seconds(to_seconds(ticks))
      end

      def to_seconds(ticks)
        Rational(ticks.to_i, 1_000_000_000)
      end
    end
  end
end
