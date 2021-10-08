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
        width: width,
        offset: offset
      }

      json[:children] = traces.any?
      json[:meta] = meta
    end
  end

  def width
    duration.to_f / trace.duration * 100
  end

  def offset
    s_start = ::Server::Clock.to_tick start
    t_start = ::Server::Clock.to_tick trace.start

    (s_start - t_start).to_f / trace.duration * 100
  end

  def title
    case name
      when 'app.controller.request.rails'
        "#{meta['controller']}##{meta['action']}"
      when 'external.run.acfs'
        'acfs.run'
      when 'external.http.acfs'
        name_for_url(meta['url'], 'acfs')
      when 'external.http.restify'
        name_for_url(meta['url'], 'restify')
      when 'view.render.template.rails'
        "#{name} #{meta['identifier'].gsub(%r{^.*/app/views/}, '')}"
      else
        name
    end
  end

  private

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
