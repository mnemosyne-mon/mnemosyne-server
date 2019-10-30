# frozen_string_literal: true

class ApplicationsController < ApplicationController
  include Controller::Platform

  def index
    @applications = Application.all
      .where(platform: platform)
  end
end
