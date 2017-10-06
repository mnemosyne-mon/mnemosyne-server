# frozen_string_literal: true

module Patch
  class Janitor
    attr_reader :pool, :frequency

    def initialize(pool, frequency)
      @pool      = pool
      @frequency = frequency
    end

    def run
      return unless frequency

      Thread.new(frequency, pool) do |t, p|
        loop do
          sleep t
          p.remove_idle
        end
      end
    end
  end

  module ConnectionPoolPatch
    def initialize(*args)
      super

      @idle_timeout = spec.config.fetch(:idle_timeout, 120).to_f

      @janitor = Janitor.new \
        self, spec.config.fetch(:janitor_frequency, 30).to_f
      @janitor.run
    end

    def queue
      @available
    end

    def stat
      synchronize do
        super.tap do |stat|
          stat[:idle_timeout] = @idle_timeout
          stat[:janitor_frequency] = @janitor&.frequency
        end
      end
    end

    def remove_idle
      synchronize do
        @available.delete_aged(@idle_timeout) do |conn|
          @connections.delete(conn)
          conn.disconnect!
        end
      end
    end
  end

  ::ActiveRecord::ConnectionAdapters::ConnectionPool.prepend ConnectionPoolPatch
end
