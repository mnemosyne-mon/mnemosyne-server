# frozen_string_literal: true

module Server
  class Heatmap
    class TimeSeries < Series
      # Time span shown as ActiveSupport::Duration
      #
      attr_reader :duration

      # Bucket time interval in nanoseconds
      #
      attr_reader :interval

      # rubocop:disable CyclomaticComplexity
      # rubocop:disable PerceivedComplexity
      # rubocop:disable AbcSize
      #
      def initialize(
        start: nil,
        stop: nil,
        duration: 1.hour,
        size: 96
      )
        stop = Time.zone.now if !start && !stop

        start = start.change(sec: 0, usec: 0) if start
        stop = stop.change(sec: 0, usec: 0) if stop

        duration = stop - start if start && stop
        start = stop - duration if duration && stop && !start
        stop = start + duration if duration && start && !stop

        super(start, stop, size)

        @duration = duration
        @interval = @duration / size.to_f
      end
      # rubocop:enable all

      protected

      def bucket_at(idx)
        r0 = start + (idx * Clock.to_seconds(interval))
        r1 = (idx + 1) == size ? stop : r0 + Clock.to_seconds(interval)

        Bucket.new r0, r1
      end

      Bucket = Struct.new(:first, :last) do
        def value
          first
        end
      end
    end
  end
end
