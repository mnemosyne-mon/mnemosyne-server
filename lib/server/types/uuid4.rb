# frozen_string_literal: true

module Server
  module Types
    class UUID4 < ActiveRecord::Type::Value
      def serialize(value)
        value.to_s
      end

      def cast(value)
        ::UUID4.try_convert(value)
      end
    end
  end
end
