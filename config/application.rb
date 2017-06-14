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

module Mnemosyne
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

    initializer 'activesupport.time_precision' do
      ::ActiveSupport::JSON::Encoding.time_precision = 9
    end

    initializer 'patch.draper-streaming' do
      ::Draper::CollectionDecorator.include ::Mnemosyne::Streaming::Collection
    end

    initializer 'patch.intervalstyle' do
      require 'active_record/connection_adapters/postgresql_adapter'

      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend \
        ::Mnemosyne::Patches::IntervalStyle
    end
  end
end
