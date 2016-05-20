class TracesController < ApplicationController
  def index
    @traces = Trace
      .where(name: 'app.rack.request')
      .order('created_at DESC')
      .limit(200)
  end

  def show
    @trace = Trace.find params[:id]
  end
end
