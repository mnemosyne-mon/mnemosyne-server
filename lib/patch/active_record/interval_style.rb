# frozen_string_literal: true

module Patch
  module IntervalStyle
    def configure_connection
      super.tap do
        execute <<-SQL
          SET intervalstyle = iso_8601;
        SQL
      end
    end
  end

  require 'active_record/connection_adapters/postgresql_adapter'

  ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend IntervalStyle
end
