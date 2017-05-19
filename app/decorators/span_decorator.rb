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
end
