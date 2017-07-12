# frozen_string_literal: true

class TracesController < ApplicationController
  include Concerns::PlatformScope
  include ::Server::Streaming::JSONStreaming

  respond_to :html, :json

  has_scope :origin, default: nil, allow_blank: true do |cr, scope, value|
    value = cr.default_origin_value if value.nil?

    if value == 'any'
      scope
    elsif (uuid = UUID4.try_convert(value))
      scope.where(origin_id: uuid.to_s)
    elsif value.nil? || value == 'null' || value == 'none'
      scope.where(origin: nil)
    else
      raise "Invalid origin: #{value}"
    end
  end

  has_scope :limit, default: 200, allow_blank: true do |_, scope, value|
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

  has_scope :ws do |_, scope, value|
    scope.where('meta @> ?', {status: value.to_i}.to_json)
  end

  has_scope :ls do |_, scope, value|
    scope.where('(stop - start) >= ?', value.to_f * 1_000_000)
  end

  has_scope :le do |_, scope, value|
    scope.where('(stop - start) < ?', value.to_f * 1_000_000)
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

    @heatmap = ::Server::Heatmap.new @traces, \
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
    @trace = trace.decorate(context: context)

    respond_with @trace
  end

  def update
    @trace = trace
    @trace.update! store: params[:store]
    @trace = @trace.decorate(context: context)

    respond_with @trace
  end

  def default_origin_value
    if (%w[origin application hostname wm wp ws] & params.keys).any?
      'any'
    else
      'none'
    end
  end

  private

  def trace
    Trace
      .where(platform: platform)
      .find(params[:id])
  end

  def context
    {
      platform: platform
    }
  end
end
