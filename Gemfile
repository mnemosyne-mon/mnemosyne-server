# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.2"

gem "config", "~> 5.5"
gem "dry-validation", "~> 1.10"
gem "forked", "~> 0.1.2"
gem "puma", "~> 6.4"
gem "rails", "~> 8.0.0"
gem "unicorn", "~> 6.0"

gem "active_record_upsert", github: "jesjos/active_record_upsert", ref: "d19fa2709749de501b351d430fd17d6832c31963"

gem "bulk_insert", "~> 1.8"
gem "hutch", "~> 1.1"
gem "pg", "~> 1.2"

gem "dry-struct", "~> 1.8.0"
gem "dry-types", "~> 1.8.0"
gem "uuid4", "~> 1.3"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "draper", "~> 4.0"
gem "has_scope", "~> 0.8.0"
gem "oj"
gem "rails-assets-manifest", "~> 3.0", ">= 3.0.0"
gem "rails-rfc6570", "~> 3.0"
gem "responders", "~> 3.0"
gem "slim"

gem "ibsciss-middleware", "~> 0.4.2"
gem "influxdb"

gem "concurrent-ruby", "~> 1.1"
gem "mnemosyne-ruby", "~> 2.0"

gem "sentry-rails"
gem "sentry-ruby"

group :development do
  gem "listen", "~> 3.9.0"
  gem "web-console", ">= 3.3.0"
end

group :development, :test do
  gem "capybara", "~> 3.32"
  gem "selenium-webdriver"

  gem "pry"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop", "~> 1.79.0"
  gem "rubocop-capybara", "~> 2.22.0"
  gem "rubocop-factory_bot", "~> 2.27.0"
  gem "rubocop-performance", "~> 1.25.0"
  gem "rubocop-rails", "~> 2.32.0"
  gem "rubocop-rspec", "~> 3.6.0"
  gem "rubocop-rspec_rails", "~> 2.31.0"
end

group :test do
  gem "factory_bot_rails"
  gem "rspec", "~> 3.9"
  gem "timecop"
end
