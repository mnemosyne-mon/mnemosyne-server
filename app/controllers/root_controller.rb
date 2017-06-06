# frozen_string_literal: true

class RootController < ApplicationController
  def index
    # TODO
  end

  def trace
    trace = Trace.find params[:id]

    redirect_to trace_path(trace.platform, trace)
  end
end
