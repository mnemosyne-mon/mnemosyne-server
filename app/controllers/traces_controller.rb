# frozen_string_literal: true

class TracesController < ApplicationController
  include Concerns::PlatformScope
  include ::Mnemosyne::Streaming::JSONStreaming

  respond_to :html, :json

  has_scope :origin, default: nil, allow_blank: true do |_, scope, value|
    if value == 'any' || value.nil?
      scope
    elsif (uuid = UUID4.try_convert(value))
      scope.where(origin_id: uuid.to_s)
    elsif value == 'null' || value == 'none'
      scope.where(origin: nil)
    else
      raise "Invalid origin: #{value}"
    end
  end

  has_scope :limit, default: 500, allow_blank: true do |_, scope, value|
    scope.limit [0, [value.to_i, 100_000].min].max
  end

  has_scope :application do |_, scope, value|
    scope.where application_id: UUID4(value)
  end

  has_scope :hostname do |_, scope, value|
    scope.where hostname: value
  end

  has_scope :wm do |_, scope, value|
    scope.where("meta->>'method' IN (?)", value.split(',').map(&:strip))
  end

  has_scope :wp do |_, scope, value|
    scope.where('meta @> ?', {path: value}.to_json)
  end

  def index
    @traces = Trace.all
      .where(platform: platform)
      .order(stop: :desc)
      .includes(:application)

    @traces = apply_scopes @traces
    @traces = @traces.decorate(context: context)

    respond_with @traces
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

    respond_with @heatmap
  end

  def show
    @trace = Trace
      .where(platform: platform)
      .find(params[:id])
      .decorate(context: context)

    respond_with @trace
  end

  private

  def context
    {
      platform: platform
    }
  end
end
