# frozen_string_literal: true

module Mnemosyne
  module Refinements
    module Arel
      module Grouping
        refine ::Arel::Nodes::Grouping do
          include ::Arel::AliasPredication
          include ::Arel::Expressions
          include ::Arel::Math
        end
      end
    end
  end
end
