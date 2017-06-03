# frozen_string_literal: true

class ApplicationsController < ApplicationController
  include Concerns::PlatformScope

  def index
    @applications = Application.all
      .where(platform: platform)
  end
end
