# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ::Server::Responder

  protect_from_forgery with: :exception
end
