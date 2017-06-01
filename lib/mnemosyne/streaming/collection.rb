# frozen_string_literal: true

module Mnemosyne
  module Streaming
    module Collection
      def to_json_stream(out, encoder:, **kwargs) # rubocop:disable MethodLength
        out << '['

        each_with_index do |object, i|
          out << ',' if i.positive?

          if object.respond_to?(:to_json_stream)
            object.to_json_stream(out, **kwargs)
          elsif object.respond_to?(:as_json)
            out << encoder.call(object.as_json(**kwargs))
          else
            out << object.to_json(**kwargs)
          end
        end

        out << ']'
      end
    end
  end
end
