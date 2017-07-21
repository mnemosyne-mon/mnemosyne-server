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
end
