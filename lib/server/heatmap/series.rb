# frozen_string_literal: true

module Server
  class Heatmap
    class Series
      attr_reader :first
      attr_reader :last
      attr_reader :size
      attr_reader :start
      attr_reader :stop

      def initialize(start, stop, size)
        @start = start
        @stop = stop
        @size = size
      end

      def at(idx)
        if idx.negative? || idx >= size
          raise IndexError.new "index #{idx} out of bounds: 0..#{size}"
        end

        bucket_at(idx)
      end

      def first
        at(0)
      end

      def last
        at(size - 1)
      end

      Bucket = Struct.new(:idx, :first, :last)

      protected

      def bucket_at(_idx)
        raise NotImplementedError.new 'subclass responsibility'
      end
    end
  end
end
