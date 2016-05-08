require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mnemosyne
  class Application < Rails::Application
    config.filter_parameters += [:password]
    config.session_store :cookie_store, key: '_mnemosyne'

    config.active_record.raise_in_transactional_callbacks = true

    config.action_dispatch.cookies_serializer = :json

    # Move some files from `config` to `app` as they have nothing to do with
    # configuring the application. Moving `application.rb` and `boot.rb` works
    # too but breaks third party gems.
    config.paths.add 'config/environments',
      with: 'app/environments', glob: "#{Rails.env}.rb"
    config.paths.add 'lib', load_path: true, eager_load: true

    config.paths['config/locales'].unshift 'app/locales'
    config.paths['config/routes.rb'].unshift 'app/routes.rb'
  end
end
