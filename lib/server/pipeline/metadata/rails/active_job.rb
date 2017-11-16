# frozen_string_literal: true

module Server
  module Pipeline
    module Metadata
      module Rails
        module ActiveJob
          def call(payload)
            Array(payload[:span]).each do |span|
              next unless span[:name] == 'app.job.perform.active_job'

              payload[:meta] ||= {}
              payload[:meta][:worker] = span.dig(:meta, :job)

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
