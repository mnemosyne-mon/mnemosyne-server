# frozen_string_literal: true

class PlatformDecorator < BaseDecorator
  delegate_all

  def applications
    object.applications.decorate.sort_by(&:title)
  end

  def serialize(**_)
    export do |out|
      out[:uuid] = id
      out[:name] = name
    end
  end
end
