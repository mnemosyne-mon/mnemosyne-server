# frozen_string_literal: true

require 'server/pipeline'

config = Rails.application.config_for('pipeline')

config.fetch(:load, []).each do |processor|
  case processor
  when Hash
    processor.each_pair do |name, config|
      cls = ::Server::Pipeline.const_get(name.to_s)
      ::Server::Pipeline.default.use cls.new(**config)
    rescue => e
      raise "Invalid pipeline configuration #{name}: #{e}"
    end
  when String
    mod = ::Server::Pipeline.const_get(processor.to_s)
    if mod.respond_to?(:call)
      ::Server::Pipeline.default.use mod
    else
      raise "Invalid pipeline processor #{mod}: Does not respond to #call."
    end
  else
    raise "Invalid pipeline configuration: #{processor}"
  end
end
