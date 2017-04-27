# frozen_string_literal: true

namespace :mnemosyne do
  desc 'Run hutch and consume messages from clients'
  task consume: :environment do
    require 'hutch'
    require 'hutch/cli'

    Rails.application.configure do
      config.cache_classes = true
      config.eager_load = true
    end

    Rails.application.eager_load!

    Hutch::Logging.logger = Rails.logger

    config = Rails.application.config_for(:hutch).symbolize_keys

    ENV['QUEUE_IDENT'] ||= config[:ident] if config.key?(:ident)

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
