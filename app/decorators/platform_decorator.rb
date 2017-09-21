# frozen_string_literal: true

class PlatformDecorator < BaseDecorator
  delegate_all

  decorates_association :applications

  def serialize(**_)
    export do |out|
      out[:uuid] = id
      out[:name] = name
    end
  end

  def last_activity_tag
    if last_activity
      h.timeago_tag last_activity
    else
      'None'
    end
  end

  def last_activity
    @last_activity ||= traces.order('stop').select('stop').last&.stop
  end
end
