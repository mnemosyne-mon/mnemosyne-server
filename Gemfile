# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 5.5'
gem 'rails', '~> 7.0.0'
gem 'unicorn', '~> 6.0'
gem 'forked', '~> 0.1.2'

gem 'active_record_upsert', '~> 0.11.0'

gem 'bulk_insert', '~> 1.8'
gem 'hutch', '~> 1.1'
gem 'pg', '~> 1.2'

gem 'dry-struct', '~> 1.4.0'
gem 'dry-types', '~> 1.6.0'
gem 'uuid4', '~> 1.3'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'draper', '~> 4.0'
gem 'has_scope', '~> 0.8.0'
gem 'oj'
gem 'rails-assets-manifest', '~> 3.0', '>= 3.0.0'
gem 'rails-rfc6570', '~> 2.4'
gem 'responders', '~> 3.0'
gem 'slim'

gem 'ibsciss-middleware', '~> 0.4.2'
gem 'influxdb'

gem 'concurrent-ruby', '~> 1.1'
gem 'mnemosyne-ruby', '~> 1.10'

gem 'sentry-rails'
gem 'sentry-ruby'

group :development do
  gem 'listen', '~> 3.7.0'
  gem 'web-console', '>= 3.3.0'

  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

group :development, :test do
  gem 'capybara', '~> 3.32'
  gem 'selenium-webdriver'

  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.11'
  gem 'rubocop-performance', '~> 1.10'
  gem 'rubocop-rails', '~> 2.9'
  gem 'rubocop-rspec', '~> 2.0'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec', '~> 3.9'
  gem 'timecop'
end
