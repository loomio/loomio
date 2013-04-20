source 'http://rubygems.org'

gem 'rails', '~> 3.2.13'
gem 'haml-rails', '~> 0.4'
gem 'devise', '~> 2.2.3'
gem 'pg'
gem 'capistrano'
gem 'jquery-rails'
gem "jquery-scrollto-rails"
gem 'inherited_resources'
gem 'formtastic' # Deprecated - use simple_form instead.
gem 'simple_form', '~> 2.0.0'
gem "country_select", "~> 1.1.3"
gem 'client_side_validations'
gem 'client_side_validations-simple_form', '~> 2.0.0'
gem 'jqplot-rails'
gem "rails-backbone"
gem 'aasm'
gem 'cancan'
gem 'acts_as_commentable_with_threading'
gem 'draper', '~> 0.11.1'
gem 'exception_notification', '~> 2.6.1'
gem 'browser', '~> 0.1.3'
gem 'rmagick', '~> 2.13.1'
gem 'gravtastic', '~> 3.2.6'
gem 'paperclip', '~> 3.4.0'
gem 'kaminari', '~> 0.13.0'
gem 'activeadmin', '~> 0.4.3'
gem 'nokogiri', '~> 1.5.9'
gem 'redcarpet', '~> 2.2.2'
gem 'rabl', '~> 0.7.3'
gem 'twitter-text', '~> 1.5.0'
gem 'jquery-atwho-rails', '~> 0.1.6'
gem 'paper_trail', '~> 2.6.3'
gem 'high_voltage', '~> 1.2.0'
gem 'rack-canonical-host', '~> 0.0.8'
gem 'delayed_job_active_record', '~> 0.3.3'
gem 'hirefireapp', '~> 0.0.8'
gem 'foreman', '~> 0.60.2'
gem 'aws-sdk', '~> 1.8.5'
gem 'rinku', '~> 1.7.2'
gem 'friendly_id'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'bootstrap-sass', '~>2.0.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'modernizr-rails'
end

group :development, :test do
  gem 'thin'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'ruby-prof', :git => 'https://github.com/wycats/ruby-prof.git'
end

group :development do
  gem 'mailcatcher'
  gem 'letter_opener'
  gem 'meta_request', '0.2.1'
  gem 'better_errors'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'spork-rails'
  gem 'awesome_print'
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem "factory_girl_rails", "~> 4.0"
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem 'cucumber-rails', :require => false
  gem 'cane', :git => 'git://github.com/square/cane.git'
  gem 'simplecov', :require => false
  gem 'flay', :require => false
  gem "rails_best_practices", :require => false
  gem 'email_spec'
  gem 'poltergeist'
end

group :staging, :production do
  gem 'newrelic_rpm', '~> 3.5.7.59'
end
