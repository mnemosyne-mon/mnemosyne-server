# frozen_string_literal: true

class FailureGroupDecorator < BaseDecorator
  delegate_all

  decorates_association :application

  def subject
    text.split("\n").first
  end

  def render_stacktrace
    h.render partial: 'stacktrace', object: stacktrace
  end

  def index_path(**params)
    h.failures_path context[:platform], **params
  end

  def self_path
    h.failure_path context[:platform], id: ids.last
  end

  def first_path
    h.failure_path context[:platform], id: ids.first
  end

  def last_path
    h.failure_path context[:platform], id: ids.last
  end

  def trace_path
    h.trace_path context[:platform], trace_id
  end
end
