# frozen_string_literal: true

module Controller
  module Range
    extend ActiveSupport::Concern

    def range
      @range ||= begin
        param = params.fetch(:range, 360).to_s.upcase

        value = if (value = try_to_i(param))
                  value.minutes
                else
                  try_to_duration(param)
                end

        value = 6.hours if value.blank?

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
      ::ActiveSupport::Duration.parse_string(str)
    rescue ArgumentError
      nil
    end
  end
end
