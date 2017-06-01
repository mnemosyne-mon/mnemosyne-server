# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  delegate_all

  def to_json(*args)
    ::Oj.dump as_json(*args), mode: :strict
  end
end
