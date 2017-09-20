# frozen_string_literal: true

module Patch
  # https://github.com/rails/arel/pull/499
  module BindParam
    # rubocop:disable MethodName
    def visit_Arel_SelectManager(o, collector)
      collector << '('
      visit(o.ast, collector) << ')'
    end
    # rubocop:enable all
  end

  ::Arel::Visitors::ToSql.prepend BindParam
end
