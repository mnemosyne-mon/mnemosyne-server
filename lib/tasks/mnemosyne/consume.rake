# frozen_string_literal: true

# rubocop:disable BlockLength
namespace :mnemosyne do
  desc 'Run hutch and consume messages from clients'
  task consume: :environment do
    require 'hutch'
    require 'hutch/cli'

    Rails.application.configure do
      config.cache_classes = true
      config.eager_load = true
    end

    STDOUT.sync = true
    STDERR.sync = true

    Rails.application.eager_load!

    Rails.logger.level = Logger::INFO

    Hutch::Logging.logger = Rails.logger

    config = Rails.application.config_for(:hutch).symbolize_keys

    ENV['QUEUE_IDENT'] ||= config[:ident] if config.key?(:ident)

    def parse(uri)
      amqp = AMQ::URI.parse(uri)

      {
        ssl: amqp[:ssl],
        host: amqp[:host],
        port: amqp[:port],
        vhost: amqp[:vhost],
        username: amqp[:user],
        password: amqp[:pass]
      }
    end

    config.reverse_merge! parse config[:uri] if config.key?(:uri)
    config.merge! parse ENV['SERVER'] if ENV.key?('SERVER')

    config[:exchange] = ENV['EXCHANGE'] || config[:exchange] || 'mnemosyne'

    Hutch::Config.set :mq_host, config[:host] if config.key?(:host)
    Hutch::Config.set :mq_port, config[:port] if config.key?(:port)
    Hutch::Config.set :mq_vhost, config[:vhost] if config.key?(:vhost)
    Hutch::Config.set :mq_username, config[:username] if config.key?(:username)
    Hutch::Config.set :mq_password, config[:password] if config.key?(:password)
    Hutch::Config.set :mq_exchange, config.fetch(:exchange, 'mnemosyne')

    Hutch::Config.set :channel_prefetch, config.fetch(:pool, 5)
    Hutch::Config.set :consumer_pool_size, config.fetch(:pool, 5)

    Hutch::Config.set :publisher_confirms, \
      config.fetch(:publisher_confirms, true)

    Hutch::Config.set :autoload_rails, true
    Hutch::Config.set :enable_http_api_use, false
    Hutch::Config.set :daemonise, false

    Hutch::CLI.new.run([])
  end
end
