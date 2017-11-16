# frozen_string_literal: true

module Server
  module Pipeline
    module Metadata
      module Rails
        module ActionController
          def call(payload)
            Array(payload[:span]).each do |span|
              next unless span[:name] == 'app.controller.request.rails'

              payload[:meta] ||= {}
              payload[:meta][:controller] = span.dig(:meta, :controller)
              payload[:meta][:action] = span.dig(:meta, :action)
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
