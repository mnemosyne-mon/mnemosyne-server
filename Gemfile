# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.2'
gem 'unicorn', '~> 5.5'

gem 'active_record_upsert', '~> 0.9.5'

gem 'bulk_insert', '~> 1.4'
gem 'hutch', '~> 0.27'
gem 'pg', '~> 1.2'

gem 'dry-struct', '~> 1.2.0'
gem 'dry-types', '~> 1.2.2'
gem 'uuid4', '~> 1.3'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'draper', '~> 3.1'
gem 'has_scope', '~> 0.7.1'
gem 'oj'
gem 'rails-assets-manifest', '~> 2.1'
gem 'rails-rfc6570', '~> 2.4'
gem 'responders', '~> 3.0'
gem 'slim'

gem 'ibsciss-middleware', '~> 0.4.2'
gem 'influxdb'

gem 'concurrent-ruby', '~> 1.0'
gem 'mnemosyne-ruby', '~> 1.9'
gem 'sentry-raven', '~> 2.13'

gem 'bootsnap', require: false

group :development do
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'web-console', '>= 3.3.0'

  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'capybara', '~> 3.30'
  gem 'selenium-webdriver'

  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.78.0'
  gem 'rubocop-rspec', '~> 1.37'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec', '~> 3.9'
  gem 'timecop'
end
