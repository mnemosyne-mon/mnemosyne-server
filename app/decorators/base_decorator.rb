# frozen_string_literal: true

class BaseDecorator < Draper::Decorator
  delegate_all

  def as_json(*, **)
    serialize(**).as_json(*, **)
  end

  def to_json(*)
    ::Oj.dump as_json(*), mode: :strict
  end

  protected

  def export(&)
    {}.tap(&)
  end
end
