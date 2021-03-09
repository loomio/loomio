source 'http://rubygems.org'

ruby '2.7.2'
gem 'rack', '2.2.3'
gem 'rails', '5.2.4.5'
gem 'rake'
gem 'pg'
gem 'active_record_extended'
gem 'haml-rails', '~> 2.0.1'
gem 'devise', '~> 4.7.3'
gem 'devise-i18n'
gem 'active_model_serializers', '~> 0.8.1'
gem 'actionpack-action_caching'
gem 'actionpack-page_caching'
gem 'cancancan'
gem 'gravtastic'
gem 'kt-paperclip'
gem 'fog-aws'
gem 'coffee-rails'
gem 'activeadmin', '~> 2.9.0'
gem 'ransack', '2.4.2'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.5.1'
gem 'paper_trail', '~> 11.1.0'
gem 'sidekiq'
gem 'friendly_id', '~> 5.3.0'
gem 'httparty', '~> 0.18.1'
gem 'browser', '~> 5.3.1'
gem "aws-sdk-s3", require: false
gem 'mini_magick'
gem 'image_processing', '~> 1.12'
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"
gem 'http_accept_language'
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'sass-rails'
gem 'uuidtools'
gem 'ahoy_matey', '~> 3.2.0'
gem 'ahoy_email', '~> 2.0.1'
gem 'geocoder', '1.6.6'
gem 'maxminddb'
gem 'oj'
gem "cld"
gem 'custom_counter_cache', github: "loomio/custom_counter_cache", branch: "rails5"
gem 'premailer-rails'
gem 'griddler', github: 'loomio/griddler'
gem "griddler-mailin", github: 'loomio/griddler-mailin'
gem 'activerecord-import', '1.0.8'
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
gem 'slack_mrkdwn'
gem 'puma'
gem 'reverse_markdown'
gem 'discard', '~> 1.2'
gem 'lograge'
gem 'video_info'
gem 'customerio', :git => 'https://github.com/customerio/customerio-ruby'

group :development, :test do
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
  gem 'rspec-rails', '~> 4.1.0'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'database_cleaner-active_record'
  gem 'database_cleaner-redis'
end

group :production do
  gem 'rack-timeout'
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'newrelic_rpm'
  gem 'heroku-deflater'
end

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
