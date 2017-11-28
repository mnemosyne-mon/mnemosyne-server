# frozen_string_literal: true

module Concerns
  module Controller
    module Range
      extend ActiveSupport::Concern

      def range
        @range ||= begin
          param = params.fetch(:range, 1440).to_s.upcase

          if (value = try_to_i(param))
            value = value.minutes
          elsif (value = try_to_duration("PT#{param}"))
            # noop
          else
            value = 6.hours
          end

          [value, platform.retention_period].min
        end
      end

      private

      def try_to_i(str, base = 10)
        Integer(str, base)
      rescue ArgumentError
        nil
      end

      def try_to_duration(str)
        ActiveSupport::Duration.parse("PT#{str}")
      rescue ArgumentError
        nil
      end
    end
  end
end
