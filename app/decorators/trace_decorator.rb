# frozen_string_literal: true

class TraceDecorator < ApplicationDecorator
  decorates_association :spans
  decorates_association :application

  def as_json(**kwargs)
    {
      id: id.to_s,
      name: name,
      start: start.iso8601(9),
      stop: stop.iso8601(9),

      activity_id: activity_id.to_s,
      platform_id: platform_id.to_s,
      origin_id: origin_id&.to_s,

      meta: {
        path: meta['path'],
        query: meta['query'],
        method: meta['method'],
        host: meta.dig('headers', 'Host'),
        user_agent: meta.dig('headers', 'User-Agent')
      }.compact
    }.compact.as_json(**kwargs)
  end

  def app_name
    application.name
  end

  def title
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
    h.trace_path(context[:platform], self)
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
