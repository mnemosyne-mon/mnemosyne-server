# frozen_string_literal: true

class TracesController < ApplicationController
  include Concerns::PlatformScope

  def index
    @traces = Trace
      .where(platform: platform)
      .includes(:spans)
      .includes(:application)
      .where(origin: nil)
      .order(stop: :desc)
      .limit(500)
      .decorate(context: context)
  end

  def show
    @trace = Trace
      .where(platform: platform)
      .find(params[:id])
      .decorate(context: context)

    render
  end

  private

  def context
    {
      platform: platform
    }
  end
end
