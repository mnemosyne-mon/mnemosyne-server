class TracesController < ApplicationController
  def index
    @traces = Trace
      .joins(:spans)
      .includes(:spans)
      .where(name: 'app.rack.request')
      .order(created_at: :desc)
      .limit(200)
      .uniq
  end

  def show
    @trace = Trace.find params[:id]
  end
end
