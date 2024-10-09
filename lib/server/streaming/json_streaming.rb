# frozen_string_literal: true

module Server
  module Streaming
    module JSONStreaming
      def _render_with_renderer_json(resource, **kwargs)
        self.content_type ||= Mime[:json]

        return resource if resource.is_a?(String)

        encoder = StreamEncoder.new(
          resource,
          format: :json,
          encoder: ->(val) { ::Oj.dump(val) },
          **kwargs,
        ) {|object, **kwa| _stream_json_fallback(object, **kwa) }

        if kwargs[:stream]
          headers["Cache-Control"] ||= "no-cache"
          headers["Transfer-Encoding"] = "chunked"
          headers.delete("Content-Length")

          Rack::Chunked::Body.new(encoder)
        else
          encoder.read
        end
      end

      private

      def _stream_json_fallback(object, encoder:, **)
        if object.respond_to?(:as_json)
          encoder.call(object.as_json(**))
        else
          object.to_json(**)
        end
      end
    end
  end
end
