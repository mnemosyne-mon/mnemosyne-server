# frozen_string_literal: true

module Model
  module Range
    def range(*, includes: false)
      where(Range.range(self, *), includes)
    end

    class << self
      def range(cls, start, stop = Time.zone.now)
        start = stop - start if start.is_a?(ActiveSupport::Duration)

        cls.arel_table[:stop].gt(start).and(cls.arel_table[:stop].lteq(stop))
      end
    end
  end
end
