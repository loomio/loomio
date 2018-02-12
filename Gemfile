source 'http://rubygems.org'

ruby '2.4.3'
gem 'rails', '~> 5.1.4'
gem 'rake'
gem 'pg', '~> 0.18.4'
gem 'haml-rails', '~> 1.0.0'
gem 'devise', '~> 4.3.0'
gem 'devise-i18n'
gem 'doorkeeper', '~> 4.2.0'
gem 'doorkeeper-i18n'
gem 'active_model_serializers', '~> 0.8.1'
gem 'private_pub', github: 'loomio/private_pub'
gem 'cancancan'
gem 'gravtastic'
gem 'paperclip', '~> 5.2.1'
gem 'coffee-rails'
gem 'activeadmin', '~> 1.2.1'
gem 'nokogiri'
gem 'twitter-text', github: 'loomio/twitter-text'
gem 'redcarpet', '~> 3.3.4'
gem 'paper_trail', '~> 8.1.2'
gem 'delayed_job', '~> 4.1.3'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'rinku'
gem 'friendly_id', '~> 5.1.0'
gem 'httparty', '~> 0.15.6'
gem 'browser', '~> 2.3.0'
gem 'fog-aws'
gem "sentry-raven"
gem 'sequenced', '~> 2.0.0'
gem 'bing_translator', '~> 5.1.0'
gem 'http_accept_language'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'sass-rails'
gem 'ahoy_matey', github: 'gdpelican/ahoy', branch: 'user-presence'
gem 'ahoy_email', '~> 0.3.1'
gem 'oj'
gem 'snorlax'
gem 'custom_counter_cache', github: "loomio/custom_counter_cache", branch: "rails5"
gem 'premailer-rails'
gem 'griddler', github: 'loomio/griddler'
gem "griddler-mailin", github: 'loomio/griddler-mailin'
gem 'activerecord-import'
gem 'discriminator', '~> 0.1.1'
gem 'has_secure_token'
gem "autoprefixer-rails"
gem 'icalendar', github: 'icalendar/icalendar', ref: '97ed9d3'
gem 'rack-attack'
gem 'js_regex'
# gem 'bootsnap', require: false

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
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
  gem "codeclimate-test-reporter", require: false
  gem 'rack_session_access'
  gem 'rspec-rails', '~> 3.7.2'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'simplecov', require: false
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'dalli'
  gem 'newrelic_rpm'
  gem 'heroku-deflater'
end

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
