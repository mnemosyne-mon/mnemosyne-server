# frozen_string_literal: true

class ApplicationDecorator < BaseDecorator
  delegate_all

  def as_json(*)
    {
      uuid: id.to_s,
      name: name
    }
  end
end
