# frozen_string_literal: true

module Patch
  module Preload
    ScopedPreload = Struct.new(:args, :scope)

    module Preloader
      def initialize(associations:, scope: nil, **)
        if associations.is_a?(ScopedPreload)
          super(associations: associations.args, scope: associations.scope, **)
        else
          super
        end
      end
    end

    module QueryMethods
      def includes(*, scope: nil, **kwargs)
        if scope
          Rails.logger.debug { "Includes with scope: #{scope}" }
          super(ScopedPreload.new([*args, kwargs], scope))
        else
          super(*, kwargs)
        end
      end

      def preload(*, scope: nil, **kwargs)
        if scope
          Rails.logger.debug { "Preload with scope: #{scope}" }
          super(ScopedPreload.new([*args, kwargs], scope))
        else
          super(*, kwargs)
        end
      end
    end

    ::ActiveRecord::Associations::Preloader.prepend Preloader
    ::ActiveRecord::Relation.prepend QueryMethods
  end
end
