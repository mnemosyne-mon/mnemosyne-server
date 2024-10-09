# frozen_string_literal: true

require "active_support/duration"

module Patch
  module ActiveSupport
    module StringDuration
      DURATION_REGEXP = /
        \A\s*
        (((?<days>\d+(\.\d+)?)d)\s*)?
        (((?<hours>\d+(\.\d+)?)h)\s*)?
        (((?<minutes>\d+(\.\d+)?)m)\s*)?
        (((?<seconds>\d+(\.\d+)?)s)\s*)?
        (((?<ms>\d+(\.\d+)?)ms)\s*)?
        (((?<us>\d+(\.\d+)?)us)\s*)?
        (((?<ns>\d+(\.\d+)?)ns)\s*)?
        \z
      /x

      DURATION_FRACTIONS = {
        days: ::ActiveSupport::Duration::SECONDS_PER_DAY,
        hours: ::ActiveSupport::Duration::SECONDS_PER_HOUR,
        minutes: ::ActiveSupport::Duration::SECONDS_PER_MINUTE,
        seconds: 1,
        ms: 0.001,
        us: 0.000001,
        ns: 0.000000001,
      }.freeze

      def parse_string(str)
        case str
          when /\A\s*\d+(\.\d+)?\s*\z/
            build(Float(str.to_s.strip))
          when DURATION_REGEXP
            m = Regexp.last_match
            build(DURATION_FRACTIONS.inject(0) do |s, f|
              m[f[0]] ? s + (Float(m[f[0]]) * f[1]) : s
            end)
          else
            raise ArgumentError
        end
      end

      ::ActiveSupport::Duration.extend(self)
    end
  end
end
