# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ::Mnemosyne::Responder

  protect_from_forgery with: :exception
end
