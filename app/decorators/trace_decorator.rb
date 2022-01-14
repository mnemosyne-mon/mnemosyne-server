# frozen_string_literal: true

class TraceDecorator < BaseDecorator
  decorates_association :spans
  decorates_association :application
  decorates_association :activity
  decorates_association :platform
  decorates_association :origin

  def as_csv(**kwargs)
    as_json(**kwargs).values
  end

  def serialize(**kwargs)
    export do |out|
      out[:uuid]     = id
      out[:name]     = name
      out[:type]     = type
      out[:start]    = start.iso8601(9)
      out[:stop]     = stop.iso8601(9)
      out[:hostname] = hostname
      out[:duration] = duration / 1_000_000.0
      out[:store]    = store

      out[:activity] = {uuid: activity_id}
      out[:platform] = platform.serialize(**kwargs)
      out[:application] = application.serialize(**kwargs)

      out[:origin] = {uuid: origin_id}
      out[:origin][:trace] = origin.trace_id if origin
      out[:stats] = stats

      out[:meta] = metainfo
    end
  end

  def stats
    {
      count: {
        db: flatten_spans.count {|span| span.name.start_with?('db.') },
        app: flatten_spans.count {|span| span.name.start_with?('app.') },
        view: flatten_spans.count {|span| span.name.start_with?('view.') },
        external: flatten_spans.count {|span| span.name.start_with?('external.') },
      }
    }
  end

  def props
    {
      routes: routes,
      trace: serialize,
      failures: object.failures.decorate.as_json,
      spans: flatten_spans
        .lazy
        .map {|span| span.decorate(context: {container: object}).serialize }
    }.to_json
  end

  def flatten_spans
    @spans ||= object.spans.after(start)
      .includes(:trace, :traces, scope: Trace.after(start))
      .includes(trace: %i[application platform])
      .includes(traces: [:application])
      .range(start, stop)
      .limit(1000)
      .flatten_hierarchy
  end

  def routes
    {
      t_url: h.t_url_rfc6570,
      traces_url: \
        h.trace_url_rfc6570.partial_expand(platform: platform.to_param)
    }
  end

  def metainfo
    case type
      when :web
        {
          path: meta['path'],
          query: meta['query'],
          method: meta['method'],
          status: meta['status'],
          host: meta.dig('headers', 'Host'),
          user_agent: meta.dig('headers', 'User-Agent'),
          controller: meta['controller'],
          action: meta['action'],
          format: meta['format']
        }
      else
        meta
    end.compact
  end

  def type
    case name
      when 'app.web.request.rack'
        :web
      when 'app.job.perform.sidekiq', 'app.messaging.receive.msgr'
        :background
      else
        :unknown
    end
  end

  def type_icon
    case type
      when :web
        h.tag.i \
          class: %w[fa fa-globe],
          title: 'Web Request',
          'aria-hidden': 'true'
      when :background
        h.tag.i \
          class: %w[fa fa-tasks],
          title: 'Background Job',
          'aria-hidden': 'true'
      else
        h.tag.i \
          class: %w[fa fa-question],
          title: 'Unknown',
          'aria-hidden': 'true'
    end
  end

  def status
    meta['status'] || ''
  end

  def method
    meta['method'] || ''
  end

  def title
    trace_title || name
  end

  def trace_title
    case name
      when 'app.web.request.rack'
        meta['path']
      when 'app.messaging.receive.msgr'
        meta.dig('delivery_info', 'routing_key')
      when 'app.job.perform.sidekiq'
        meta['worker']
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
    format '%.2f ms', duration_ms
  end

  private

  def origin_url
    return unless origin

    h.trace_url platform, origin.trace
  end
end
