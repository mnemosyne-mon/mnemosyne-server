# frozen_string_literal: true

class TraceConsumer
  include Hutch::Consumer

  consume '#'

  if ENV['QUEUE_IDENT'].present?
    queue_name "mnemosyne.server.#{ENV['QUEUE_IDENT'].strip}"
  else
    queue_name 'mnemosyne.server'
  end

  def process(message)
    return if message.body.fetch(:platform, 'default') == 'default'

    try = 0
    begin
      ::Mnemosyne::Builder.create!(message.body)
    rescue ActiveRecord::RecordNotUnique
      retry if (try += 1) < 2
      raise
    end
  ensure
    ::ActiveRecord::Base.clear_active_connections!
  end
end
