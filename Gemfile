source 'http://rubygems.org'

ruby '2.0.0'
gem 'rails', '~> 3.2.14'
gem 'haml-rails', '~> 0.4'
gem 'devise', '~> 3.1.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-browserid'
gem 'pg', '~> 0.17.0'
gem 'capistrano'
gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails'
gem 'inherited_resources', '~> 1.4.1'
gem 'simple_form', '~> 2.1.0'
gem 'country_select', '~> 1.2.0'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'jqplot-rails', '~> 0.3'
gem 'rails-backbone', '~> 0.7.2'
gem 'aasm', '~> 3.0.3'
gem 'cancan', '~> 1.6.10'
gem 'draper', '~> 0.11.1' # can this be removed?
gem 'browser', '~> 0.1.3'
gem 'rmagick', '~> 2.13.1'
gem 'gravtastic', '~> 3.2.6'
gem 'paperclip', '~> 3.4.0'
gem 'kaminari', '~> 0.13.0'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'nokogiri', '~> 1.6.0'
gem 'twitter-text', '~> 1.6.3'
gem 'jquery-atwho-rails', '~> 0.4.1'
gem 'redcarpet', '~> 3.0.0'
gem 'twitter-text', '~> 1.6.3'
gem 'paper_trail', '~> 2.7.2'
gem 'unicorn', '~> 4.6.3'
gem 'rack-canonical-host', '~> 0.0.8'
gem 'delayed_job_active_record', '~> 4.0.0'
gem 'foreman', '~> 0.63.0'
gem 'rinku', '~> 1.7.3'
gem 'friendly_id', '~> 4.0.10.1'
gem 'httparty', '~> 0.11.0'
gem 'timecop', '~> 0.6.3'
gem 'pg_search', '~> 0.7.0'
gem 'strong_parameters', '~> 0.2.1'
gem 'exception_notification', '~> 2.6.1'
gem 'fog'
gem 'roadie', '~> 2.4.1'
gem 'valid_email', '~> 0.0.4'
gem 'font-awesome-sass-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'bootstrap-sass', '~> 2.3.2.2'
  gem 'uglifier', '~> 2.2.1'
  gem 'modernizr-rails', '~> 2.6.2'
  gem 'jquery-fileupload-rails', '~> 0.4.1'
end

group :development, :test do
  gem 'thin', '~> 1.5.1'
  gem 'pry-rails', '~> 0.3.2' # Use this instead of debugger
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'faker', '~> 1.2.0'
  gem 'rspec-rails', '~> 2.14.0'
  gem 'shoulda-matchers', '~> 2.3.0'
  gem 'capybara', '~> 2.1.0'
  gem 'database_cleaner', '~> 1.1.1'
  gem 'selenium-webdriver', '~> 2.35.1'
  gem 'ruby-prof'
end

group :development do
  gem 'meta_request', '~> 0.2.4'
  gem 'better_errors', '~> 0.6.0'
  gem 'guard', '~> 1.6.1'
  gem 'guard-spork', '~> 1.4.1'
  gem 'guard-rspec', '~> 2.3.3'
  gem 'rb-inotify', '~> 0.8.8', :require => false
  gem 'rb-fsevent', '~> 0.9.1', :require => false
  gem 'rb-fchange', '~> 0.0.5', :require => false
  gem 'launchy', '~> 2.0.5'
  gem 'spork-rails', '~> 3.2.1'
  gem 'awesome_print', '~> 1.0.2'
  gem 'quiet_assets', '~> 1.0.2'
end

group :test do
  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'email_spec', '~> 1.2.1'
  gem 'poltergeist', '~> 1.3.0'
  gem 'webmock', '~> 1.9.0'
  gem 'vcr', '~> 2.5.0'
  gem "codeclimate-test-reporter", require: nil
  gem 'rack_session_access'
end

group :staging, :production do
  gem 'memcachier'
  gem 'dalli'
  gem 'newrelic_rpm', '~> 3.5.7.59'
  gem 'heroku-deflater'
end
