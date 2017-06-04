# frozen_string_literal: true

class SpanDecorator < BaseDecorator
  decorates_association :origin

  def as_json(*) # rubocop:disable MethodLength
    {
      uuid: id.to_s,
      name: name,
      title: title,
      start: start.iso8601(9),
      stop: stop.iso8601(9),
      metric: {
        width: width,
        offset: offset
      }
    }
  end

  def width
    duration.to_f / trace.duration * 100
  end

  def offset
    s_start = ::Mnemosyne::Clock.to_tick start
    t_start = ::Mnemosyne::Clock.to_tick trace.start

    (s_start - t_start).to_f / trace.duration * 100
  end

  def style
    "width: #{width}%; margin-left: #{offset}%"
  end

  def title # rubocop:disable MethodLength
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

    if (app = origin.first&.application)
      url.host = app.name.split(%r{[/\s]+})[1].downcase
    end

    url.port = nil
    url.to_s
  end
end
