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
    ::Mnemosyne::Builder.create!(message.body)
  rescue ActiveRecord::RecordNotUnique
    retry if !@retry && (@retry = true)
    raise
  ensure
    ::ActiveRecord::Base.clear_active_connections!
  end
end
