# frozen_string_literal: true

module Server
  module Patches
    module IntervalStyle
      def configure_connection
        super.tap do
          execute <<-SQL
            SET intervalstyle = iso_8601;
          SQL
        end
      end
    end
  end
end
