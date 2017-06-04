# frozen_string_literal: true

class BaseDecorator < Draper::Decorator
  delegate_all

  def to_json(*args)
    ::Oj.dump as_json(*args), mode: :strict
  end
end
