# frozen_string_literal: true

class FailuresController < ApplicationController
  include Concerns::Controller::Platform
  include Concerns::Controller::Range

  has_scope :limit, default: 200, allow_blank: true do |_, scope, value|
    scope.limit [0, [value.to_i, 100_000].min].max
  end

  has_scope :application do |controller, scope, value|
    scope.where application: controller.platform.applications.resolve(value)
  end

  has_scope :hostname do |_, scope, value|
    scope.where hostname: value
  end

  has_scope :range, default: true, allow_blank: true do |controller, scope, _|
    scope.range controller.range
  end

  def index
    @failures = FailureGroup
      .where(platform: platform)
      .includes(:application, :platform)

    @failures = apply_scopes @failures
    @failures = @failures.decorate(context: context)
  end

  def show
    @failure = platform.failures.find(params[:id]).decorate
  end

  private

  def context
    {
      platform: platform
    }
  end
end
