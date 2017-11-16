# frozen_string_literal: true

require 'influxdb'

module Server
  module Pipeline
    module Metrics
      class Influx
        def initialize(database, **kwargs)
          if database.respond_to?(:write_point)
            @client = database
          else
            @client = ::InfluxDB::Client.new(database.to_s, **kwargs)
          end
        end

        def name
          ::Server::Pipeline::Metrics::Influx
        end

        # rubocop:disable AbcSize
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def call(payload)
          values = {
            total: ::Server::Clock
              .to_seconds(payload[:stop] - payload[:start]).to_f
          }

          tags = {
            platform: payload[:platform],
            hostname: payload[:hostname],
            application: payload[:application],
            errors: payload.dig(:errors).present?
          }

          case payload[:name]
            when 'app.web.request.rack'
              type = 'web'

              tags[:format] = payload.dig(:meta, :format)
              tags[:method] = payload.dig(:meta, :method)
              tags[:status] = payload.dig(:meta, :status)

              action = payload.dig(:meta, :action)
              controller = payload.dig(:meta, :controller)

              tags[:action] = action if action
              tags[:controller] = controller if controller

              if controller && action
                tags[:instance] = "#{controller}##{action}"
              elsif controller
                tags[:instance] = controller
              end

            when 'app.job.perform.sidekiq'
              type = 'background'

              tags[:type] = 'job'
              tags[:queue] = payload.dig(:meta, :queue)
              tags[:worker] = payload.dig(:meta, :worker)

            when 'app.messaging.receive.msgr'
              type = 'messaging'

              tags[:type] = 'message'
              tags[:consumer] = payload.dig(:meta, :route, :consumer)
              tags[:action] = payload.dig(:meta, :route, :action)
              tags[:route] = payload.dig(:meta, :delivery_info, :routing_key)

              tags[:instance] = "#{tags[:consumer]}##{tags[:action]}"
          end

          yield(payload)

          return unless type

          data = {
            tags: tags,
            values: values,
            timestamp: payload[:stop]
          }

          @client.write_point(type, data, 'ns')
        end
        # rubocop:enable all
      end
    end
  end
end
