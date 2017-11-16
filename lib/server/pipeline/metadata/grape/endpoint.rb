# frozen_string_literal: true

module Server
  module Pipeline
    module Metadata
      module Grape
        module Endpoint
          def call(payload)
            Array(payload[:span]).each do |span|
              next unless span[:name] == 'app.controller.request.grape'

              payload[:meta] ||= {}
              payload[:meta][:controller] = span.dig(:meta, :endpoint)
              payload[:meta][:format] = span.dig(:meta, :format)

              break
            end

            yield(payload)
          end

          module_function :call
        end
      end
    end
  end
end
