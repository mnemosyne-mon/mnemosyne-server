# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'csv'

module Server
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks patch server])

    config.filter_parameters += %i[passw secret token _key crypt salt certificate otp ssn]
    config.session_store :cookie_store, key: '_mnemosyne', same_site: :lax
    config.action_dispatch.cookies_serializer = :json

    config.paths['config/locales'].unshift 'app/locales'
    # config.paths.add 'app/consumers', eager_load: true

    logger = ActiveSupport::Logger.new($stdout)
    config.logger = ActiveSupport::TaggedLogging.new(logger)
    config.log_level = :info

    config.time_zone = 'Europe/Berlin'
    config.active_record.default_timezone = :utc

    # Currently required at least to run specs
    config.active_record.partial_inserts = true

    config.relative_url_root = ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/').to_s

    config.action_controller.asset_host = proc {|_, request|
      if request
        [
          '//',
          request.host_with_port,
          request.headers['HTTP_X_RELATIVE_URL_ROOT']
        ].join
      end
    }
  end
end
