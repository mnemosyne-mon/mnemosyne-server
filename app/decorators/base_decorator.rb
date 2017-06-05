# frozen_string_literal: true

class BaseDecorator < Draper::Decorator
  delegate_all

  def as_json(*args, **kwargs)
    serialize(**kwargs).as_json(*args, **kwargs)
  end

  def to_json(*args)
    ::Oj.dump as_json(*args), mode: :strict
  end

  protected

  def export
    {}.tap(&Proc.new)
  end
end
