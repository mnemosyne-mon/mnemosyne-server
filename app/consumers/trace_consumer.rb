# frozen_string_literal: true

require 'server/pipeline'

class TraceConsumer
  include Hutch::Consumer

  consume '#'

  if ENV['QUEUE_IDENT'].present?
    queue_name "mnemosyne.server.#{ENV['QUEUE_IDENT'].strip}"
  elsif Rails.env.production?
    queue_name 'mnemosyne.server'
  else
    queue_name "mnemosyne.#{Rails.env}"
  end

  def process(message)
    ::Server::Pipeline.call(message.body)
  rescue ActiveRecord::RecordNotUnique
    retry if !@retry && (@retry = true)
    raise
  ensure
    ::ActiveRecord::Base.connection_handler.clear_active_connections!
  end
end
