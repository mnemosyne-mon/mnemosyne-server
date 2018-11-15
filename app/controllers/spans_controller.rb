# frozen_string_literal: true

class SpansController < ApplicationController
  include Concerns::Controller::Platform

  def show
    @span = Span.find params[:id]
  end

  private

  def context
    {
      platform: platform,
    }
  end
end
