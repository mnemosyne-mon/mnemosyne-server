# frozen_string_literal: true

class FailureDecorator < BaseDecorator
  delegate_all

  decorates_association :trace

  def serialize(**_)
    export do |out|
      out['uuid'] = id
      out['type'] = type
      out['text'] = text
    end
  end

  def subject
    text.split("\n").first
  end

  delegate :hostname, to: :trace
  delegate :type_icon, to: :trace

  def application_name
    trace.application.title
  end

  def date
    trace.stop
  end

  def render_stacktrace
    h.render partial: 'stacktrace', object: stacktrace
  end

  def index_path(**params)
    h.failures_path platform, **params
  end

  def self_path
    h.failure_path platform, self
  end

  def trace_path
    h.trace_path platform, trace_id
  end
end
