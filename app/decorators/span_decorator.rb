# frozen_string_literal: true

class SpanDecorator < BaseDecorator
  decorates_association :origin

  def serialize(**)
    export do |json|
      json[:uuid] = id
      json[:name] = name
      json[:title] = title
      json[:start] = start.iso8601(9)
      json[:stop] = stop.iso8601(9)
      json[:duration] = duration / 1_000_000.0

      json[:metric] = {
        width:,
        offset:,
      }

      json[:application] = {
        name: trace.application.name,
      }

      json[:activity] = {
        uuid: trace.activity_id,
      }

      json[:trace] = {
        uuid: trace.id,
        url: h.trace_url(trace.platform, trace),
      }

      json[:children] = traces.any?
      json[:spans] = spans.map(&:serialize)
      json[:meta] = meta
    end
  end

  def width
    duration.to_f / container.duration * 100
  end

  def offset
    s_start = ::Server::Clock.to_tick start
    t_start = ::Server::Clock.to_tick container.start

    (s_start - t_start).to_f / container.duration * 100
  end

  def title
    case name
      when "app.controller.request.rails"
        "#{meta['controller']}##{meta['action']}"
      when "external.run.acfs"
        "acfs.run"
      when "external.http.acfs"
        name_for_url(meta["url"], "acfs")
      when "external.http.restify"
        name_for_url(meta["url"], "restify")
      when "view.render.template.rails"
        "#{name} #{meta['identifier'].gsub(%r{^.*/app/views/}, '')}"
      else
        name
    end
  end

  def stats
    [make_stats, spans.map(&:stats)].flatten.reduce(&:add)
  end

  Stats = Struct.new(:app, :db, :view, :external) do
    def add(other)
      Stats.new(
        app + other.app,
        db + other.db,
        view + other.view,
        external + other.external,
      )
    end

    def as_json
      {
        db:,
        app:,
        view:,
        external:,
      }
    end
  end

  private

  def spans
    return [] unless context.key?(:container)

    # We explicitly use `#length` to *not* run an additional COUNT query on
    # the database, but to get the size of the preloaded `traces`
    # association.
    return [] if traces.length != 1

    @spans ||= begin
      trace = traces.take
      trace.spans
        .after(start)
        .includes(:trace, :traces, scope: Trace.after(trace.start))
        .includes(trace: %i[application platform])
        .includes(traces: [:application])
        .range(trace.start, trace.stop)
        .limit(1000)
        .decorate(context: {container:})
    end
  end

  def make_stats
    if span.name.start_with?("app.")
      Stats.new(1, 0, 0, 0)
    elsif span.name.start_with?("db.")
      Stats.new(0, 1, 0, 0)
    elsif span.name.start_with?("view.")
      Stats.new(0, 0, 1, 0)
    elsif span.name.start_with?("external.")
      Stats.new(0, 0, 0, 1)
    else
      Stats.new(0, 0, 0, 0)
    end
  end

  def container
    context.fetch(:container) { trace }
  end

  def name_for_url(url, scheme)
    url = ::URI.parse(url)
    url.scheme = scheme

    if (app = traces.first&.application)
      names = app.name.split(%r{[/\s]+})
      url.host = (names[1] || names[0]).downcase
    end

    url.port = nil
    url.to_s
  end
end
