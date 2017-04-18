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

    Hutch::Config.set :mq_exchange, 'mnemosyne'
    Hutch::Config.set :channel_prefetch, 25
    Hutch::Config.set :consumer_pool_size, 25

    Hutch::Config.set :autoload_rails, true
    Hutch::Config.set :enable_http_api_use, false

    Hutch::CLI.new.run([])
  end
end
