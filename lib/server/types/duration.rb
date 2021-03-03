# frozen_string_literal: true

module Server
  module Types
    class Duration < ActiveRecord::Type::Value
      def type
        :interval
      end

      def serialize(value)
        case value
          when ::ActiveSupport::Duration
            value.iso8601(precision: precision)
          when ::Numeric
            # Sometimes operations on Times returns just float number of
            # seconds so we need to handle that.
            # Example:
            #   Time.current - (Time.current + 1.hour)
            #   # => -3600.000001776 (Float)
            value.seconds.iso8601(precision: precision)
          else
            super
        end
      end

      def cast_value(value)
        case value
          when ::ActiveSupport::Duration
            value
          when ::String
            begin
              ::ActiveSupport::Duration.parse(value)
            rescue ::ActiveSupport::Duration::ISO8601Parser::ParsingError
              nil
            end
          else
            super
        end
      end
    end
  end
end
