source 'http://rubygems.org'

ruby '3.2.2'
gem 'rails', '7.0.4.2'
gem 'rack', '2.2.7'
gem 'rake'
gem 'pg'
gem 'active_record_extended'
gem 'haml-rails', '~> 2.1.0'
gem 'devise', '~> 4.9.2'
gem 'devise-i18n'
gem 'active_model_serializers', '~> 0.8.1'
gem 'actionpack-action_caching'
gem 'actionpack-page_caching'
gem 'cancancan'
gem 'gravtastic'
gem 'coffee-rails'
gem 'activeadmin', '~> 2.13.1'
gem 'ransack', '3.2.1'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.6.0'
gem 'paper_trail', '~> 14.0.0'
gem 'sidekiq', '~> 6.5.7'
gem 'friendly_id', '~> 5.5.0'
gem 'httparty', '~> 0.21.0'
gem 'browser', '~> 5.3.1'
gem "aws-sdk-s3", require: false
gem "google-cloud-storage", "~> 1.11", require: false
gem 'image_processing', '~> 1.12'
gem "ruby-vips"
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"
gem 'http_accept_language'
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'sass-rails'
gem 'uuidtools'
gem 'maxminddb'
gem 'oj'
gem "cld"
gem 'custom_counter_cache'
gem 'premailer-rails'
gem 'activerecord-import', '1.4.1'
gem 'discriminator', '~> 0.1.1'
gem 'icalendar'
gem 'rack-attack'
gem 'bootsnap', require: false
gem 'redis-objects'
gem 'redis-rails'
gem 'hiredis'
gem 'connection_pool'
gem 'ruby-saml'
gem 'google-cloud-translate'
gem 'puma'
gem 'reverse_markdown'
gem 'discard', '~> 1.2'
gem 'lograge'
gem 'video_info'
gem 'blazer'
gem 'terminal-table'
gem 'tzinfo-data'

group :development, :test do
  gem 'listen'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
  gem 'rails-controller-testing'
end

group :development do
  gem 'spring'
  gem "spring-commands-rspec"
end

group :test do
  gem 'webmock'
  gem 'rack_session_access'
  gem 'rspec-rails', '~> 6.0.2'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'database_cleaner-active_record'
  gem 'database_cleaner-redis'
end

group :production do
  gem 'rack-timeout'
end

if Dir.exist?('engines/loomio_subs')
  gem 'loomio_subs', path: 'engines/loomio_subs'
end