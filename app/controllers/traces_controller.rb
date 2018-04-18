# frozen_string_literal: true

# rubocop:disable ClassLength
class TracesController < ApplicationController
  include Concerns::Controller::Platform
  include Concerns::Controller::Range

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

  has_scope :application do |controller, scope, value|
    scope.where application_id: controller.platform.applications.resolve(value)
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

  has_scope :wc do |_, scope, value|
    scope.where('meta @> ?', {controller: value}.to_json)
  end

  has_scope :wa do |_, scope, value|
    scope.where('meta @> ?', {action: value}.to_json)
  end

  has_scope :ls do |_, scope, value|
    scope.where('(stop - start) >= ?', value.to_f * 1_000_000)
  end

  has_scope :le do |_, scope, value|
    scope.where('(stop - start) < ?', value.to_f * 1_000_000)
  end

  has_scope :range, default: true, allow_blank: true do |controller, scope, _|
    scope.range controller.range
  end

  FILTER_PARAMS = %w[origin application hostname wm wp ws wc wa ls le].freeze

  def index
    @traces = platform.traces
      .order(stop: :desc)
      .includes(:application)

    # Force PostgreSQL to use filter indexes if filtered are specified
    # instead of favoring the ordered stop index.
    if (FILTER_PARAMS & params.keys).any? # rubocop:disable IfUnlessModifier
      @traces = @traces.order(:id)
    end

    @traces = apply_scopes @traces
    @traces = @traces.decorate(context: context)

    respond_with @traces
  end

  # rubocop:disable MethodLength
  def heatmap
    @traces = apply_scopes platform.traces

    max = @traces.maximum('(stop - start)')

    @heatmap = ::Server::Heatmap.new @traces, \
      time: {
        stop: Time.zone.now,
        duration: range,
        size: params.fetch(:tbs, 96).to_i
      },
      latency: {
        start: 0,
        interval: (max / 99.0),
        size: 100
      }

    respond_with @heatmap
  end
  # rubocop:enable all

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
    if (FILTER_PARAMS & params.keys).any?
      'any'
    else
      'none'
    end
  end

  private

  def trace
    Trace.find(params[:id])
  end

  def context
    {
      platform: platform
    }
  end
end
