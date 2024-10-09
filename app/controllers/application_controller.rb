# frozen_string_literal: true

require "server/responder"

class ApplicationController < ActionController::Base
  self.responder = ::Server::Responder

  protect_from_forgery with: :exception

  def default_url_options
    if (root = request.headers["HTTP_X_RELATIVE_URL_ROOT"]).present?
      super.merge original_script_name: root
    else
      super
    end
  end
end
