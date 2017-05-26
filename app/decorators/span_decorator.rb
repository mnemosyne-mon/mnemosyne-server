# frozen_string_literal: true

class SpanDecorator < ApplicationDecorator
  decorates_association :origin

  def style
    trace_duration = trace.duration

    width = duration.to_f / trace_duration * 100

    s_start = ::Mnemosyne::Clock.to_tick start
    t_start = ::Mnemosyne::Clock.to_tick trace.start

    offset = s_start - t_start
    offset = offset.to_f / trace_duration * 100

    "width: #{width}%; margin-left: #{offset}%"
  end

  def title
    case name
      when 'app.controller.request.rails'
        "#{meta['controller']}##{meta['action']}"
      when 'external.run.acfs'
        "acfs.run"
      when 'external.http.acfs'
        "#{name_for_url(meta['url'], 'acfs')}"
      when 'external.http.restify'
        "#{name_for_url(meta['url'], 'restify')}"
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
