# frozen_string_literal: true

require 'middleware'

module Server
  module Pipeline
    class << self
      def call(*args)
        default.call(*args)
      end

      def default
        @default ||= ::Middleware::Builder.new(runner_class: Runner) do |b|
          b.use ::Server::Pipeline::Metadata::Grape::Endpoint
          b.use ::Server::Pipeline::Metadata::Rails::ActionController
          b.use ::Server::Pipeline::Metadata::Rails::ActiveJob
        end
      end
    end

    class Runner
      def initialize(stack)
        @kickoff = build(stack)
      end

      def call(env)
        @kickoff.call(env)
      end

      private

      # rubocop:disable MethodLength
      def build(stack)
        app = ::Server::Builder.new

        stack.reverse.inject(app) do |nxt, crt|
          mw, args, block = crt

          if mw.is_a?(Class)
            mw.new(nxt, *args, &block)
          elsif mw.respond_to?(:call)
            ->(env) { mw.call(env, *args, &nxt.method(:call)) }
          else
            raise \
              "Invalid middleware: Does not respond to `#call`: #{mw.inspect}"
          end
        end
      end
      # rubocop:enable all
    end
  end
end
