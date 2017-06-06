# frozen_string_literal: true

# rubocop:disable ClassLength
class TraceDecorator < BaseDecorator
  decorates_association :spans
  decorates_association :application
  decorates_association :activity
  decorates_association :platform
  decorates_association :origin

  def serialize(**kwargs) # rubocop:disable MethodLength, AbcSize
    export do |out|
      out[:uuid]     = id
      out[:name]     = name
      out[:type]     = type
      out[:start]    = start.iso8601(9)
      out[:stop]     = stop.iso8601(9)
      out[:hostname] = hostname
      out[:duration] = duration / 1_000_000.0

      out[:activity] = activity.serialize(**kwargs)
      out[:platform] = platform.serialize(**kwargs)
      out[:application] = application.serialize(**kwargs)

      out[:origin] = {uuid: origin_id}
      out[:origin][:trace] = origin.trace_id if origin

      out[:meta] = {
        path: meta['path'],
        query: meta['query'],
        method: meta['method'],
        host: meta.dig('headers', 'Host'),
        user_agent: meta.dig('headers', 'User-Agent')
      }.compact
    end
  end

  def props
    {
      routes: routes,
      trace: serialize,
      spans: spans.map(&:serialize)
    }.to_json
  end

  def routes
    {
      traces_url: h.traces_url + '{/id}'
    }
  end

  def type
    case name
      when 'app.web.request.rack'
        :web
      when 'app.job.perform.sidekiq'
        :job
      else
        :unknown
    end
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

  def duration_text
    format "%.2f ms", duration_ms
  end

  private

  def origin_url
    return unless origin

    h.trace_url platform, origin.trace
  end
end
