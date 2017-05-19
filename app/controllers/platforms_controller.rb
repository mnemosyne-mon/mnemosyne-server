# frozen_string_literal: true

class PlatformsController < ApplicationController
  def index
    @platforms = Platform.all

    render layout: 'global'
  end

  def show
    @platform = Platform.find(UUID(params[:id]))

    redirect_to platform_traces_url(@platform)
  end
end
