# frozen_string_literal: true

class TraceConsumer
  include Hutch::Consumer

  consume '#'

  if ENV['QUEUE_IDENT'].present?
    queue_name "mnemosyne.server.#{ENV['QUEUE_IDENT'].strip}"
  else
    queue_name 'mnemosyne.server'
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def process(message)
    content = message.body

    ActiveRecord::Base.transaction do
      app = Application.fetch content[:application]

      trace_data = {
        id: content[:uuid],
        origin_id: content[:origin],
        application: app,
        transaction_id: content[:transaction],
        name: content[:name],
        start: Integer(content[:start]),
        stop: Integer(content[:stop]),
        meta: content[:meta]
      }

      trace = Trace.create! trace_data

      Array(content[:span]).each do |span|
        span_data = {
          id: span[:uuid],
          name: span[:name],
          trace: trace,
          start: Integer(span[:start]),
          stop: Integer(span[:stop]),
          meta: span[:meta]
        }

        Span.create! span_data
      end
    end
  ensure
    ::ActiveRecord::Base.clear_active_connections!
  end
end
