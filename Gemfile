source 'http://rubygems.org'

ruby '3.4.7'
gem 'rails', '7.2.2.1'
gem 'rack', '2.2.21'
gem 'uri', '1.1.1'
gem 'rake'
gem 'pg'
gem 'active_record_extended'
gem 'haml-rails', '~> 3.0.0'
gem 'devise', '~> 4.9.4'
gem 'devise-i18n'
gem 'devise-pwned_password'
gem 'active_model_serializers', '~> 0.8.1'
gem 'actionpack-action_caching'
gem 'actionpack-page_caching'
gem 'cancancan'
gem 'gravtastic'
gem 'activeadmin', '~> 3.4.0'
gem 'ransack', '4.4.1'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.6.1'
gem 'paper_trail', '~> 17.0.0'
gem 'sidekiq', '~> 6.5.12'
gem 'friendly_id', '~> 5.6.0'
gem 'httparty', '~> 0.24.2'
gem 'browser', '~> 6.2.0'
gem "aws-sdk-s3", require: false
gem "ruby-openai"
gem "google-cloud-storage", "~> 1.57", require: false
gem 'image_processing', '~> 1.14'
gem "ruby-vips"
gem "stackprof"
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"
gem 'http_accept_language'
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'dartsass-sprockets'
gem 'uuidtools'
gem 'maxminddb'
gem "cld"
gem 'custom_counter_cache'
gem 'premailer-rails'
gem 'activerecord-import', '2.2.0'
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
gem 'discard', '~> 1.4'
gem 'lograge'
gem 'video_info'
gem 'blazer'
gem 'terminal-table'
gem 'tzinfo-data'
gem 'pg_search'
gem 'i18n-timezones'
gem 'actionpack-cloudflare'
gem 'victor', require: false
gem 'concurrent-ruby', '1.3.6' # can remove in rails 7.1

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
  gem 'rails-controller-testing'
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'webmock'
  gem 'rack_session_access'
  gem 'drb'
  gem 'rspec-rails', '~> 7.1.1'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'database_cleaner-active_record'
  gem 'database_cleaner-redis'
end

group :production do
  gem 'rack-timeout'
  gem 'thruster'
end

if Dir.exist?('engines/loomio_subs')
  gem 'loomio_subs', path: 'engines/loomio_subs'
end
