# frozen_string_literal: true

class TracesController < ApplicationController
  include Concerns::PlatformScope

  def index
    @traces = Trace.all
      .where(platform: platform)
      .where(origin: nil)
      .includes(:spans)
      .includes(:application)
      .order(stop: :desc)
      .limit(500)
      .decorate(context: context)
  end

  def heatmap
    @traces = Trace.all
      .where(platform: platform)
      .where(origin: nil)

    @heatmap = ::Mnemosyne::Heatmap.new @traces, \
      time: {
        stop: Time.zone.now,
        duration: 1.hour,
        size: params.fetch(:tbs, 96).to_i
      },
      latency: {
        start: 0,
        interval: 25_000_000,
        size: 79
      }

    respond_to do |format|
      format.html
      format.json { render json: @heatmap.as_json }
    end
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
