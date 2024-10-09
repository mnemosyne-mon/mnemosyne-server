# frozen_string_literal: true

require "server/streaming/json_streaming"

class TracesController < ApplicationController
  include Controller::Platform
  include Controller::Range

  include ::Server::Streaming::JSONStreaming

  # Skip an implicit time range filter if at least on these scopes have been
  # applied.
  RANGE_EXCLUDE_KEYS = %i[activity]

  respond_to :html, :json
  respond_to :csv, only: :index

  has_scope :origin, default: nil, allow_blank: true do |cr, scope, value|
    value = cr.default_origin_value if value.nil?

    if value == "any"
      scope
    elsif (uuid = UUID4.try_convert(value))
      scope.where(origin_id: uuid.to_s)
    elsif value.nil? || value == "null" || value == "none"
      scope.where(origin: nil)
    else
      raise "Invalid origin: #{value}"
    end
  end

  has_scope :limit, default: 200, allow_blank: true do |_, scope, value|
    scope.limit [0, [value.to_i, 100_000].min].max
  end

  has_scope :activity do |_, scope, value|
    scope.where activity_id: UUID4.try_convert(value.to_s)
  end

  has_scope :application do |controller, scope, value|
    scope.where application_id: controller.platform.applications.resolve(value)
  end

  has_scope :hostname do |_, scope, value|
    scope.where hostname: value
  end

  has_scope :name do |_, scope, value|
    scope.where name: value.to_s
  end

  has_scope :wm do |_, scope, value|
    scope.where("meta->>'method' IN (?)", value.split(",").map(&:strip))
  end

  has_scope :wp do |_, scope, value|
    scope.where("meta @> ?", {path: value}.to_json)
  end

  has_scope :ws do |_, scope, value|
    scope.where("meta @> ?", {status: value.to_i}.to_json)
  end

  has_scope :wc do |_, scope, value|
    scope.where("meta @> ?", {controller: value}.to_json)
  end

  has_scope :wa do |_, scope, value|
    scope.where("meta @> ?", {action: value}.to_json)
  end

  has_scope :ls do |_, scope, value|
    scope.where("(stop - start) >= interval ?", ::ActiveSupport::Duration.parse_string(value).iso8601)
  end

  has_scope :le do |_, scope, value|
    scope.where("(stop - start) < interval ?", ::ActiveSupport::Duration.parse_string(value).iso8601)
  end

  has_scope :meta, type: :hash do |_, scope, value|
    scope.where("meta @> ?", value.to_json)
  end

  has_scope :range, default: true, allow_blank: true do |controller, scope, value|
    if !value && (controller.send(:current_scopes).keys & RANGE_EXCLUDE_KEYS).any?
      scope
    else
      scope.range controller.range
    end
  end

  FILTER_PARAMS = %w[origin application hostname wm wp ws wc wa ls le].freeze

  def index
    @traces = platform.traces
      .order(stop: :desc)
      .includes(:application)

    # Force PostgreSQL to use filter indexes if filtered are specified
    # instead of favoring the ordered stop index.
    if (FILTER_PARAMS & params.keys).any?
      @traces = @traces.order(:id)
    end

    @traces = apply_scopes @traces
    @traces = @traces.decorate(context:)

    respond_with @traces
  end

  def show
    @trace = trace.decorate(context:)

    respond_with @trace
  end

  def update
    @trace = trace
    @trace.update! store: params[:store]
    @trace = @trace.decorate(context:)

    respond_with @trace
  end

  def default_origin_value
    if (FILTER_PARAMS & params.keys).any?
      "any"
    else
      "none"
    end
  end

  private

  def trace
    Trace.find(params[:id])
  end

  def context
    {
      platform:,
    }
  end
end
