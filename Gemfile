# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 4.0'
gem 'rails', '~> 5.2.0'
gem 'unicorn', '~> 5.5'

gem 'active_record_upsert', '~> 0.9.5'

gem 'bulk_insert', '~> 1.4'
gem 'hutch', '~> 0.21'
gem 'pg', '~> 1.0'

gem 'dry-struct', '~> 1.0.0'
gem 'dry-types', '~> 1.1.1'
gem 'uuid4', '~> 1.3'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'draper', '~> 3.1'
gem 'has_scope', '~> 0.7.1'
gem 'oj'
gem 'rails-rfc6570', '~> 2.1'
gem 'responders', '~> 3.0'
gem 'slim'
gem 'webpacker', '~> 2.0'

gem 'ibsciss-middleware', '~> 0.4.2'
gem 'influxdb'

gem 'mnemosyne-ruby', '~> 1.7'
gem 'sentry-raven', '~> 2.9'

gem 'bootsnap', require: false

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'capybara', '~> 3.27'
  gem 'selenium-webdriver'

  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.73.0'
  gem 'rubocop-rspec', '~> 1.34'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec', '~> 3.1'
  gem 'timecop'
end
