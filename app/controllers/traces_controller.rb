class TracesController < ApplicationController
  def index
    @traces = Trace
      .joins(:spans)
      .includes(:spans)
      .where(name: 'app.web.request.rack')
      .order(start: :desc)
      .limit(200)
      .uniq
  end

  def show
    @trace = Trace.find params[:id]
  end
end
