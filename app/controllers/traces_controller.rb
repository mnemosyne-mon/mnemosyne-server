# frozen_string_literal: true

class TracesController < ApplicationController
  def index
    traces = Trace
      .joins(:spans)
      .includes(:spans)
      .includes(:application)
      .where(name: 'app.web.request.rack')
      .order(start: :desc)
      .limit(200)
      .uniq

    render locals: {traces: traces}
  end

  def show
    trace = Trace.find params[:id]

    render locals: {trace: trace}
  end
end
