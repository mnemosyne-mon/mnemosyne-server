# frozen_string_literal: true

namespace :mnemosyne do
  desc 'Run hutch and consume messages from clients'
  task consume: :environment do
    require 'etc'

    require 'hutch'
    require 'hutch/cli'

    $stdout.sync = true
    $stderr.sync = true

    Zeitwerk::Loader.eager_load_all

    case ENV.fetch('LOG_LEVEL', 'warn')
      when 'debug'
        Rails.logger.level = Logger::DEBUG
      when 'info'
        Rails.logger.level = Logger::INFO
      when 'warn'
        Rails.logger.level = Logger::WARN
      when 'error'
        Rails.logger.level = Logger::ERROR
    end

    Hutch::Logging.logger = Rails.logger

    configuration = begin
      if (file = Rails.root.join("config/hutch.#{Rails.env}.yml")).exist? ||
         (file = Rails.root.join('config/hutch.yml')).exist?

        require 'erb'
        (YAML.safe_load(ERB.new(file.read).result, aliases: true) || {})[Rails.env] || {}
      else
        raise 'Could not load configuration. No such file - config/hutch.yml'
      end
    end.symbolize_keys

    profile = ENV.fetch('PROFILE', :default)
    config = configuration.fetch(profile) do
      warn "Connection profile not found: #{profile}"
      exit 1
    end.symbolize_keys

    Rails.logger.info("Using connection profile: #{profile}")

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
    config[:pool] = ENV['POOL']&.to_i || config[:pool] || 5
    config[:worker] = ENV['WORKER']&.to_i || config[:worker] || Etc.nprocessors

    Hutch::Config.set :mq_host, config[:host] if config.key?(:host)
    Hutch::Config.set :mq_port, config[:port] if config.key?(:port)
    Hutch::Config.set :mq_vhost, config[:vhost] if config.key?(:vhost)
    Hutch::Config.set :mq_username, config[:username] if config.key?(:username)
    Hutch::Config.set :mq_password, config[:password] if config.key?(:password)
    Hutch::Config.set :mq_exchange, config.fetch(:exchange, 'mnemosyne')

    Hutch::Config.set :channel_prefetch, config.fetch(:prefetch) { config[:pool] * 2 }
    Hutch::Config.set :consumer_pool_size, config[:pool]

    Hutch::Config.set :publisher_confirms,
      config.fetch(:publisher_confirms, true)

    Hutch::Config.set :autoload_rails, true
    Hutch::Config.set :enable_http_api_use, false
    Hutch::Config.set :daemonise, false

    Hutch::Config[:error_handlers] << Hutch::ErrorHandlers::Sentry.new

    if config[:worker] > 1
      require 'forked'
      process_manager = Forked::ProcessManager.new(logger: Rails.logger, process_timeout: 10)

      ActiveRecord::Base.clear_all_connections!

      config[:worker].times do
        process_manager.fork('worker') do
          Rails.application.reloader.wrap do
            Hutch::CLI.new.run([])
          end
        end
      end

      process_manager.wait_for_shutdown
    else
      Hutch::CLI.new.run([])
    end
  end
end
