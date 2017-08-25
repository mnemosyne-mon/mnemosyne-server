# frozen_string_literal: true

module Patch
  module QueuePatch
    Entry = Struct.new(:conn, :time) do
      def initialize(conn)
        super conn, Time.now.utc
      end

      def age
        Time.now.utc - time
      end
    end

    def add(element)
      synchronize do
        @queue.unshift Entry.new(element)
        @cond.signal
      end
    end

    def delete_aged(max_age)
      synchronize do
        return if @num_waiting.positive? || @queue.empty?

        yield @queue.pop.conn while @queue.last.age > max_age
      end
    end

    def ages
      @queue.map(&:age)
    end

    private

    def remove
      @queue.shift.conn
    end
  end

  ::ActiveRecord::ConnectionAdapters::ConnectionPool::Queue.prepend QueuePatch
end
