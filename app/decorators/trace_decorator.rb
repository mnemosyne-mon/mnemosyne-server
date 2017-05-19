# frozen_string_literal: true

class TraceDecorator < ApplicationDecorator
  decorates_association :spans

  def duration_ms
    (trace.duration.to_f / 1_000_000).round(3)
  end

  def self_path
    h.platform_trace_path(context[:platform], self)
  end
end
