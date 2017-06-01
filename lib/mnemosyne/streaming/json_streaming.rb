# frozen_string_literal: true

module Mnemosyne
  module Streaming
    module JSONStreaming
      # rubocop:disable MethodLength
      def _render_with_renderer_json(resource, **kwargs)
        self.content_type ||= Mime[:json]

        return resource if resource.is_a?(String)

        encoder = StreamEncoder.new \
          resource,
          format: :json,
          encoder: ->(val) { ::Oj.dump(val) },
          **kwargs,
          &method(:_stream_json_fallback)

        headers['Cache-Control'] ||= 'no-cache'
        headers['Transfer-Encoding'] = 'chunked'
        headers.delete('Content-Length')

        Rack::Chunked::Body.new(encoder)
      end
      # rubocop:enable all

      private

      def _stream_json_fallback(object, encoder:, **kwargs)
        if object.respond_to?(:as_json)
          encoder.call(object.as_json(**kwargs))
        else
          object.to_json(**kwargs)
        end
      end
    end
  end
end
