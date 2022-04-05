# frozen_string_literal: true

module Patch
  module Preload
    ScopedPreload = Struct.new(:args, :scope)

    module Preloader
      def initialize(associations:, scope: nil, **kwargs)
        if associations.is_a?(ScopedPreload)
          super(associations: associations.args, scope: associations.scope, **kwargs)
        else
          super
        end
      end
    end

    module QueryMethods
      def includes(*args, scope: nil, **kwargs)
        if scope
          puts "Includes with scope: #{scope}"
          super ScopedPreload.new([*args, kwargs], scope)
        else
          super(*args, kwargs)
        end
      end

      def preload(*args, scope: nil, **kwargs)
        if scope
          puts "Preload with scope: #{scope}"
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
