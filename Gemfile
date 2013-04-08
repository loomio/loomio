source 'http://rubygems.org'

gem 'rails', '~> 3.2.12'
gem "haml-rails"
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
gem 'exception_notification'
gem 'browser'
gem 'rmagick'
gem 'gravtastic'
gem 'paperclip'
gem 'kaminari'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'nokogiri'
gem 'redcarpet', :git => 'https://github.com/vmg/redcarpet.git'
gem 'rabl'
gem 'twitter-text', :git => 'https://github.com/twitter/twitter-text-rb.git'
gem 'jquery-atwho-rails'
gem 'paper_trail', '~> 2'
gem "high_voltage"
gem 'thin'
gem 'rack-canonical-host'
gem 'delayed_job_active_record'
gem 'hirefireapp'
gem 'foreman'
gem 'aws-sdk'
gem 'rinku'
gem "friendly_id", "~> 4.0.9"


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
  gem 'poltergeist', :git => 'https://github.com/jonleighton/poltergeist.git'
end

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'aws-sdk'
end
