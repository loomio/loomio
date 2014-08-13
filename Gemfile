source 'http://rubygems.org'

ruby '2.1.2'

gem 'rails', '~> 4.1.4'
gem 'rake'
gem 'pg', '~> 0.17.1'
gem 'pg_search', '~> 0.7.6'
gem 'haml-rails'
gem 'devise', '~> 3.2.4'
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-google-oauth2', '~> 0.2.5'
gem 'omniauth-facebook', '~> 1.6.0'
gem 'omniauth-browserid'
gem 'omnicontacts', '~> 0.3.4'
gem 'jquery-rails', '~> 3.1.1'
gem 'jquery-ui-rails', '~> 5.0.0'
gem 'simple_form', '3.1.0.rc1'
gem 'country_select'
gem 'cancancan'
gem 'rmagick', '~> 2.13.3'
gem 'gravtastic'
gem 'paperclip', '~> 4.2.0'
gem 'kaminari'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'nokogiri'
gem 'twitter-text'
gem 'jquery-atwho-rails', '~> 0.4.11'
gem 'redcarpet', '~> 3.1.2'
gem 'paper_trail', '~> 3.0.3'
gem 'unicorn', '~> 4.8.3'
gem 'rack-canonical-host'
gem 'delayed_job', '~> 4.0.2'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'foreman'
gem 'rinku'
gem 'friendly_id', '~> 5.0.4'
gem 'httparty'
gem 'airbrake'
gem 'fog'
gem 'roadie-rails', '~> 1.0.2'
gem 'rabl' # can probably take out soon
gem 'sequenced', '~> 1.6.0'
gem 'closure_tree', '~> 4.6.3'
gem 'ruby-progressbar'
gem 'bing_translator'
gem 'librato-rails'
gem 'http_accept_language'
gem 'browser'
gem 'activerecord-postgres-hstore'
gem 'intercom'
gem 'intercom-rails'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'minitest'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'underscore-rails'
  gem "font-awesome-sass"
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'bootstrap-sass', '~> 3.1.1'
  gem 'modernizr-rails'
  gem 'jquery-fileupload-rails'
  gem 'momentjs-rails'
end

group :development, :test do
  gem 'timecop'
  gem 'thin'
  gem 'pry-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'ruby-prof'
  gem 'parallel_tests'
end

group :development do
  gem 'spring'
  gem "spring-commands-cucumber"
  gem "spring-commands-rspec"
  #gem 'bullet'
  gem 'launchy'
  gem 'awesome_print'
  gem 'quiet_assets'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'email_spec'
  gem 'poltergeist'
  gem 'webmock'
  #gem 'vcr'
  gem "codeclimate-test-reporter", require: false
  gem 'rack_session_access'
end

group :production do
  gem 'sprockets-rails', require: 'sprockets/railtie'
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'delayed-plugins-airbrake'
  gem 'memcachier'
  gem 'dalli'
  gem 'newrelic_rpm'
  gem 'heroku-deflater'
end
