# frozen_string_literal: true

class RootController < ApplicationController
  layout 'global'

  def index
    # TODO
  end

  def trace
    unless search_term
      render 'traces/trace_not_found', status: :not_found
      return
    end

    if (trace = Trace.find_by(id: search_term))
      redirect_to trace_path(trace.platform, trace)
      return
    end

    if (trace = Trace.where(activity_id: search_term).first)
      redirect_to traces_path(trace.platform, activity: search_term)
      return
    end

    if (span = Span.find_by(id: search_term))
      redirect_to trace_path(span.platform, span.trace, anchor: "sm-#{span.id}")
      return
    end

    render 'traces/trace_not_found', status: :not_found
  end

  private

  def search_term
    UUID4.try_convert(params[:id].strip)
  end
end
