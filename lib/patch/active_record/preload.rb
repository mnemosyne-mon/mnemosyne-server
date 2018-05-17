# frozen_string_literal: true

module Patch
  module Preload
    ScopedPreload = Struct.new(:args, :scope)

    module Preloader
      def preload(records, associations, preload_scope = nil)
        return super unless associations.is_a?(ScopedPreload)

        super(records, associations.args, associations.scope)
      end
    end

    module QueryMethods
      def includes(*args, scope: nil, **kwargs)
        if scope
          super ScopedPreload.new([*args, kwargs], scope)
        else
          super(*args, kwargs)
        end
      end

      def preload(*args, scope: nil, **kwargs)
        if scope
          super ScopedPreload.new([*args, kwargs], scope)
        else
          super(*args, kwargs)
        end
      end
    end

    ::ActiveRecord::Associations::Preloader.prepend Preloader
    ::ActiveRecord::Relation.prepend QueryMethods
  end
end
