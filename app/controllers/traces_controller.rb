# frozen_string_literal: true

class TracesController < ApplicationController
  before_action :platform

  def index
    @traces = Trace
      .includes(:spans)
      .includes(:application)
      .where(origin: nil)
      .order(stop: :desc)
      .limit(500)
      .decorate(context: context)
  end

  def show
    @trace = Trace
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

  def platform
    @platform = Platform.find UUID params[:platform_id]
  end
end
