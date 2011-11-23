source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem "haml"
gem 'devise', '1.4.9'
gem 'mysql2'
gem 'capistrano'
gem 'jquery-rails'
gem 'inherited_resources'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end
#gem 'jquery-rails'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem 'machinist', '>= 2.0.0.beta2'
  gem 'faker'
  gem "rspec-rails", ">= 2.6.0.rc2"
  gem "capybara"

  gem 'machinist', '>= 2.0.0.beta2'
  gem "faker"
end

group :development do
  gem 'sqlite3'
end

group :test do
  # Pretty printed test output
#  gem 'turn', :require => false
end
