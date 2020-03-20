# frozen_string_literal: true

require 'server/pipeline'

class TraceConsumer
  include Hutch::Consumer

  consume '#'
  arguments 'x-queue-mode' => 'lazy'

  if ENV['QUEUE_IDENT'].present?
    queue_name "mnemosyne.server.#{ENV['QUEUE_IDENT'].strip}"
  else
    queue_name 'mnemosyne.server'
  end

  def process(message)
    ::Server::Pipeline.call(message.body)
  rescue ActiveRecord::RecordNotUnique
    retry if !@retry && (@retry = true)
    raise
  ensure
    ::ActiveRecord::Base.clear_active_connections!
  end
end
