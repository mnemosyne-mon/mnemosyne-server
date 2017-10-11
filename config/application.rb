# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Server
  class Application < Rails::Application
    config.load_defaults 5.1

    config.filter_parameters += [:password]
    config.session_store :cookie_store, key: '_mnemosyne'
    config.action_dispatch.cookies_serializer = :json

    config.paths.add 'lib', load_path: true, eager_load: true, autoload: true
    config.paths['config/locales'].unshift 'app/locales'

    logger = ActiveSupport::Logger.new(STDOUT)
    config.logger = ActiveSupport::TaggedLogging.new(logger)
    config.log_level = :info

    config.time_zone = 'Europe/Berlin'
    config.active_record.default_timezone = :utc

    initializer 'patch' do
      require 'patch/all'

      # Force new ConnectionPool after patching
      ::ActiveRecord::Base.establish_connection
    end

    initializer 'activesupport.time_precision' do
      ::ActiveSupport::JSON::Encoding.time_precision = 9
    end

    initializer 'patch.draper.streaming' do
      ::Draper::CollectionDecorator.include ::Server::Streaming::Collection
    end

    initializer 'activerecord.types' do
      ActiveRecord::Type.register :uuid, ::Server::Types::UUID4, override: true
      ActiveRecord::Type.register :interval, ::Server::Types::Duration
    end

    initializer 'pipeline' do |app|
      pipeline = app.config_for('pipeline')

      if (config = pipeline['influx'])
        database = config.fetch('database')
        host     = config['host']
        username = config['username']
        password = config['password']

        kwargs = {
          host: host,
          async: true,
          username: username,
          password: password,
          time_precision: 'ns'
        }

        ::Server::Pipeline.default.use \
          ::Server::Pipeline::Metrics::Influx.new(database, **kwargs)
      end
    end
  end
end
