class TraceConsumer
  include Hutch::Consumer

  consume '#'
  queue_name 'mnemosyne.server'

  def process(message)
    content = message.body

    ActiveRecord::Base.transaction do
      app = Application.find content[:application]

      _trace = {
        id: content[:uuid],
        origin_id: content[:origin],
        application: app,
        transaction_id: content[:transaction],
        name: content[:name],
        start: Integer(content[:start]),
        stop: Integer(content[:stop]),
        meta: content[:meta]
      }

      trace = Trace.create! _trace

      Array(content[:span]).each do |span|
        _span = {
          id: span[:uuid],
          name: span[:name],
          trace: trace,
          start: Integer(span[:start]),
          stop: Integer(span[:stop]),
          meta: span[:meta]
        }

        Span.create! _span
      end
    end
  end
end
