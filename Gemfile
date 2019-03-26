source 'http://rubygems.org'

ruby '2.6.1'
gem 'rails', '~> 5.2.2.1'
gem 'actioncable'
gem 'rake'
gem 'pg', '~> 1.1.4'
gem 'activerecord-nulldb-adapter'
gem 'haml-rails', '~> 1.0.0'
gem 'devise', '~> 4.6.1'
gem 'devise-i18n'
gem 'doorkeeper', '~> 4.4.2'
gem 'doorkeeper-i18n'
gem 'active_model_serializers', '~> 0.8.1'
gem 'cancancan'
gem 'gravtastic'
gem 'paperclip', '~> 6.1.0'
gem 'coffee-rails'
gem 'activeadmin', '~> 1.4.3'
gem 'ransack', '2.1.1'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.4.0'
gem 'paper_trail', '~> 10.2.0'
gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '~> 4.1.3'
gem 'rinku'
gem 'friendly_id', '~> 5.2.5'
gem 'httparty', '~> 0.16.4'
gem 'browser', '~> 2.5.3'
gem "aws-sdk-s3", require: false
gem 'mini_magick'
gem 'image_processing', '~> 1.2'
gem "sentry-raven"
gem 'sequenced', '~> 3.1.1'
gem 'http_accept_language'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'sass-rails'
gem 'uuidtools'
gem 'ahoy_matey', '~> 2.2.0'
gem 'ahoy_email', '~> 0.5.2'
gem 'geocoder', '1.5.1'
gem 'maxminddb'
gem 'oj'
gem 'snorlax', '0.1.8'
gem 'custom_counter_cache', github: "loomio/custom_counter_cache", branch: "rails5"
gem 'premailer-rails'
gem 'griddler', github: 'loomio/griddler'
gem "griddler-mailin", github: 'loomio/griddler-mailin'
gem 'activerecord-import', '1.0.0'
gem 'discriminator', '~> 0.1.1'
gem 'has_secure_token'
gem "autoprefixer-rails"
gem 'icalendar'
gem 'rack-attack'
gem 'js_regex'
gem 'bootsnap', require: false
gem 'redis-rails'
gem 'ruby-saml'
gem 'google-cloud-translate'
gem 'discourse-diff'

group :development, :test do
  gem 'parallel_tests'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
  gem 'database_cleaner'
  gem 'gemrat'
  gem 'derailed'
  gem 'rails-controller-testing'
end

group :development do
  gem "stackprof"
  gem 'spring'
  gem "spring-commands-rspec"
  gem 'bullet'
  gem 'launchy'
  gem 'awesome_print'
end

group :test do
  gem 's3_uploader'
  gem 'poltergeist'
  gem 'webmock'
  gem 'rack_session_access'
  gem 'rspec-rails', '~> 3.8.2'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'simplecov', require: false
end

group :production do
  gem 'puma'
  gem 'rack-timeout'
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'newrelic_rpm'
  gem 'heroku-deflater'
end

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
