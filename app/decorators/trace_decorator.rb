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

    if span && (title = span.title)
      return title
    end

    trace_title || name
  end

  def trace_title
    case name
      when 'app.web.request.rack'
        meta['path']
    end
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

  def render_information
    case name
      when 'app.web.request.rack'
        h.render 'traces/web/rack'
      else
        'Nothing'
    end
  end
end
