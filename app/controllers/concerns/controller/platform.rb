# frozen_string_literal: true

module Controller
  module Platform
    extend ActiveSupport::Concern

    included do
      before_action :platform

      def platform
        @platform ||= ::Platform.where(name: params[:platform]).take!
      end
    end
  end
end
