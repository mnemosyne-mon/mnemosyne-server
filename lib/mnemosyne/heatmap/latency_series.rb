# frozen_string_literal: true

module Mnemosyne
  class Heatmap
    class LatencySeries < Series
      attr_reader :interval

      def initialize(
        start: 0,
        stop: nil,
        interval: 25_000_000,
        size: 79
      )
        stop = start + size * interval unless stop
        interval = Rational((stop - start), size).to_i

        super(start, stop, size)

        @interval = interval
      end
      # rubocop:enable all
    end
  end
end
