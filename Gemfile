source 'http://rubygems.org'

ruby '2.0.0'
gem 'rails', '~> 3.2.13'
gem 'haml-rails', '~> 0.4'
gem 'devise', '~> 2.2.3'
gem 'pg', '~> 0.14.1'
gem 'capistrano'
gem 'jquery-rails', '2.3.0'
gem 'inherited_resources', '~> 1.4.1'
gem 'simple_form', '~> 2.0.4'
gem 'country_select', '~> 1.1.3'
gem 'client_side_validations', '~> 3.2.1'
gem 'client_side_validations-simple_form', '~> 2.0.1'
gem 'jqplot-rails', '~> 0.3'
gem 'rails-backbone', '~> 0.7.2'
gem 'aasm', '~> 3.0.3'
gem 'cancan', '~> 1.6.7'
gem 'draper', '~> 0.11.1' # can this be removed?
gem 'browser', '~> 0.1.3'
gem 'rmagick', '~> 2.13.1'
gem 'gravtastic', '~> 3.2.6'
gem 'paperclip', '~> 3.4.0'
gem 'kaminari', '~> 0.13.0'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'nokogiri', '~> 1.5.9'
gem 'redcarpet', '~> 2.2.2'
gem 'rabl', '~> 0.7.3'
gem 'twitter-text', '~> 1.5.0'
gem 'jquery-atwho-rails', '~> 0.1.6'
gem 'paper_trail', '~> 2.6.3'
gem 'unicorn', '~> 4.6.2'
gem 'rack-canonical-host', '~> 0.0.8'
gem 'delayed_job_active_record', '~> 0.3.3'
gem 'hirefireapp', '~> 0.0.8'
gem 'foreman', '~> 0.60.2'
gem 'rinku', '~> 1.7.2'
gem 'piwik_analytics', '~> 1.0.1'
gem 'friendly_id', '~> 4.0.9'
gem 'httparty', '~> 0.11.0'
gem 'timecop', '~> 0.6.1'
gem 'pg_search', '~> 0.7.0'
gem 'strong_parameters', '~> 0.2.1'
gem 'exception_notification', '~> 2.6.1'
gem 'bounscale'
gem 'zip'

# NOTE: sass-rails should be inside :assets group, but currently there is an issue with activeadmin
#       which does not allow us to do this
#
#       https://github.com/rails/sass-rails/issues/38#issuecomment-2046678
gem 'sass-rails',   '~> 3.2.6'
gem 'coffee-rails', '~> 3.2.2'
gem 'fog'
gem 'roadie', '~> 2.3.4'
gem 'valid_email', '~> 0.0.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~> 2.3.1.0'
  gem 'uglifier', '~> 1.1.0'
  gem 'modernizr-rails', '~> 2.6.2'
  gem 'jquery-fileupload-rails', '~> 0.4.1'
end

group :development, :test do
  gem 'thin', '~> 1.5.0'
  gem 'pry-rails', '~> 0.3.0' # Use this instead of debugger
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker', '~> 1.0.1'
  gem 'rspec-rails', '~> 2.0'
  gem 'shoulda-matchers', '~> 1.2.0'
  gem 'capybara', '~> 2.1.0'
  gem 'database_cleaner', '~> 0.9.1'
  gem 'selenium-webdriver', '~> 2.25.0'
  gem 'ruby-prof'
  gem 'sauce', '~> 3.0.3'
  gem 'sauce-connect'
  gem 'parallel_tests'
  gem 'sauce-cucumber'
end

group :development do
  gem 'meta_request', '~> 0.2.4'
  gem 'better_errors', '~> 0.6.0'
  gem 'rb-inotify', '~> 0.8.8', :require => false
  gem 'rb-fsevent', '~> 0.9.1', :require => false
  gem 'rb-fchange', '~> 0.0.5', :require => false
  gem 'launchy', '~> 2.0.5'
  gem 'awesome_print', '~> 1.0.2'
  gem 'quiet_assets', '~> 1.0.2'
end

group :test do
  gem 'cucumber-rails', '~> 1.3.0', :require => false
  gem 'email_spec', '~> 1.2.1'
  gem 'poltergeist', '~> 1.3.0'
  # gem 'webmock', '~> 1.9.0'
  # gem 'vcr', '~> 2.5.0'
end

group :staging, :production do
  gem 'memcachier'
  gem 'dalli'
  gem 'newrelic_rpm', '~> 3.5.7.59'
  gem 'heroku-deflater'
end
