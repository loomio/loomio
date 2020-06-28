source 'http://rubygems.org'

ruby '2.6.6'
gem 'rack', '2.2.3'
gem 'rails', '5.2.4.3'
gem 'actioncable'
gem 'rake'
gem 'pg'
gem 'activerecord-nulldb-adapter'
gem 'haml-rails', '~> 2.0.1'
gem 'devise', '~> 4.7.2'
gem 'devise-i18n'
gem 'active_model_serializers', '~> 0.8.1'
gem 'cancancan'
gem 'gravtastic'
gem 'kt-paperclip'
gem 'fog-aws'
gem 'coffee-rails'
gem 'activeadmin', '~> 2.7.0'
gem 'ransack', '2.3.2'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.5.0'
gem 'paper_trail', '~> 10.3.1'
gem 'sidekiq'
gem 'friendly_id', '~> 5.3.0'
gem 'httparty', '~> 0.18.1'
gem 'browser', '~> 4.2.0'
gem "aws-sdk-s3", require: false
gem 'mini_magick'
gem 'image_processing', '~> 1.11'
gem "sentry-raven"
gem 'sequenced', '~> 3.2.0'
gem 'http_accept_language'
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'sass-rails'
gem 'uuidtools'
gem 'ahoy_matey', '~> 3.0.4'
gem 'ahoy_email', '~> 1.1.0'
gem 'geocoder', '1.6.3'
gem 'maxminddb'
gem 'oj'
gem 'custom_counter_cache', github: "loomio/custom_counter_cache", branch: "rails5"
gem 'premailer-rails'
gem 'griddler', github: 'loomio/griddler'
gem "griddler-mailin", github: 'loomio/griddler-mailin'
gem 'activerecord-import', '1.0.5'
gem 'discriminator', '~> 0.1.1'
gem "autoprefixer-rails"
gem 'icalendar'
gem 'rack-attack'
gem 'bootsnap', require: false
gem 'redis-rails'
gem 'hiredis'
gem 'ruby-saml'
gem 'google-cloud-translate', '1.4.0'
gem 'slack_mrkdwn'
gem 'puma'
gem 'reverse_markdown'
gem 'discard', '~> 1.2'

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

group :development do
  gem 'spring'
  gem "spring-commands-rspec"
end

group :test do
  gem 'webmock'
  gem 'rack_session_access'
  gem 'rspec-rails', '~> 4.0.1'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
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
