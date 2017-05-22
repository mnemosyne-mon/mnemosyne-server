# frozen_string_literal: true

class TraceDecorator < ApplicationDecorator
  decorates_association :spans
  decorates_association :application

  def app_name
    application.name
  end

  def title
    span = spans
      .sort_by(&:start)
      .find {|s| s.name =~ /^app\.controller\./ }

    return span.title if span

    name
  end

  def full_title
    "#{application.name}: #{title}"
  end

  def duration_ms
    (trace.duration.to_f / 1_000_000).round(3)
  end

  def self_path
    h.platform_trace_path(context[:platform], self)
  end
end
