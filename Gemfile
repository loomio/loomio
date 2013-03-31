source 'http://rubygems.org'

gem 'rails', '~> 3.2.12'
gem 'haml-rails', '~> 0.4'
gem 'devise', '~> 2.2.3'
gem 'devise_invitable', '~> 1.0.0'
gem 'pg', '~> 0.14.1'
gem 'capistrano'
gem 'jquery-rails'
gem "jquery-scrollto-rails"
gem 'inherited_resources'
gem 'formtastic' # Deprecated - use simple_form instead.
gem 'simple_form', '~> 2.0.0'
gem 'client_side_validations'
gem 'client_side_validations-simple_form', '~> 2.0.0'
gem 'jqplot-rails'
gem "rails-backbone"
gem 'coffee-filter'
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
gem 'activeadmin'
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

# NOTE: sass-rails should be inside :assets group, but currently there is an issue with activeadmin
#       which does not allow us to do this
#
#       https://github.com/rails/sass-rails/issues/38#issuecomment-2046678
gem 'sass-rails',   '~> 3.2.6'
gem 'coffee-rails', '~> 3.2.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~>2.3.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'modernizr-rails'
end

group :development, :test do
  gem 'thin'
  gem 'debugger'
  gem "factory_girl_rails", "~> 4.0"
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver', '2.25.0'
  gem 'letter_opener'
  gem 'mailcatcher'
end

group :development do
  gem 'meta_request', '0.2.1'
  gem 'better_errors'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'launchy'
  gem 'spork-rails'
  gem 'awesome_print'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'email_spec'
  gem 'poltergeist', :git => 'https://github.com/jonleighton/poltergeist.git'
  gem 'webmock', '~> 1.9.0'
  gem 'vcr', '~> 2.4.0'
end

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'aws-sdk'
end
