# frozen_string_literal: true

class SpansController < ApplicationController
  include Controller::Platform

  def show
    @span = Span.find params[:id]
  end

  private

  def context
    {
      platform:,
    }
  end
end
