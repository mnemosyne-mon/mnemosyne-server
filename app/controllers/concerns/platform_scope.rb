# frozen_string_literal: true

module Concerns
  module PlatformScope
    extend ActiveSupport::Concern

    included do
      before_action :platform

      def platform
        @platform ||= ::Platform.where(name: params[:platform_id]).take!
      end
    end
  end
end
