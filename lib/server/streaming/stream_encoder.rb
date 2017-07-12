# frozen_string_literal: true

module Server
  module Streaming
    class StreamEncoder
      def initialize(object, format:, **kwargs, &fallback)
        @object = object
        @kwargs = kwargs
        @format = format
        @fallback = fallback
      end

      def each(&block)
        enumerator.each(&block)
      end

      def read
        StringIO.new.tap {|io| call(io, @object) }.string
      end

      private

      def enumerator
        Enumerator.new {|yielder| call(yielder, @object) }
      end

      def call(yielder, object)
        if object.respond_to?(:"to_#{@format}_stream")
          object.send(:"to_#{@format}_stream", yielder, **@kwargs)
        elsif object.respond_to?(:to_stream)
          object.to_stream(yielder, format: @format, **@kwargs)
        elsif @fallback
          yielder << @fallback.call(object, format: @format, **@kwargs)
        else
          yielder << object.send(:"to_#{@format}", **@kwargs).to_s
        end
      end
    end
  end
end
