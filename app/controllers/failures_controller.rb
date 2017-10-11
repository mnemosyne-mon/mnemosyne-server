# frozen_string_literal: true

class FailuresController < ApplicationController
  include Concerns::PlatformScope

  has_scope :limit, default: 200, allow_blank: true do |_, scope, value|
    scope.limit [0, [value.to_i, 100_000].min].max
  end

  has_scope :application do |_, scope, value|
    scope.where application_id: UUID4(value)
  end

  has_scope :hostname do |_, scope, value|
    scope.where hostname: value
  end

  def index
    @failures = platform
      .failures
      .joins(:trace)
      .order('traces.stop DESC')

    @failures = apply_scopes @failures
    @failures = @failures.decorate
  end

  def show
    @failure = platform.failures.find(params[:id]).decorate
  end
end
