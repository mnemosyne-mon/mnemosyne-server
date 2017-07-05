# frozen_string_literal: true

class ApplicationDecorator < BaseDecorator
  delegate_all

  def serialize(*)
    export do |out|
      out[:uuid] = id
      out[:name] = name
    end
  end

  def title
    super || name
  end
end
