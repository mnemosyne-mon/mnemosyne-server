# frozen_string_literal: true

module Server
  class Responder < ::ActionController::Responder
    def has_view_rendering? # rubocop:disable Naming/PredicateName
      return false if format == :json

      super
    end
  end
end
