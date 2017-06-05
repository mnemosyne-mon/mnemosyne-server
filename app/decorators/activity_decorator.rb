# frozen_string_literal: true

class ActivityDecorator < BaseDecorator
  delegate_all

  def serialize(**kwargs)
    export do |out|
      out[:uuid] = id
    end
  end
end
