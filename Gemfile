source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem "haml-rails"
gem 'devise', '~> 2.0.0'
gem 'devise_invitable', '~> 1.0.0'
gem 'pg'
gem 'capistrano'
gem 'jquery-rails'
gem 'inherited_resources'
gem 'formtastic' # Deprecated. Use simple_form instead.
gem 'simple_form'
gem 'jqplot-rails'
gem "rails-backbone"
gem 'coffee-filter'
gem 'acts-as-taggable-on', '~> 2.2.2', :git => 'https://github.com/mbleigh/acts-as-taggable-on.git'
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
gem 'paper_trail', '~> 2'
gem "high_voltage"
gem 'thin'

# NOTE: sass-rails should be inside :assets group, but currently there is an issue with activeadmin
#       which does not allow us to do this
#
#       https://github.com/rails/sass-rails/issues/38#issuecomment-2046678
gem 'sass-rails',   '~> 3.2.5'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'twitter-bootstrap-rails'
  gem 'bootstrap-sass', '~>2.0.3'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'modernizr-rails', '~> 2.0.6'
end

group :development, :test do
  gem 'thin'
  gem 'debugger'
  gem "factory_girl_rails", "~> 4.0"
  gem 'faker'
  gem 'rspec-rails'
  gem 'ruby-prof', :git => 'https://github.com/wycats/ruby-prof.git'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'jasminerice'
  gem 'guard-jasmine'
  gem 'selenium-webdriver', '2.25.0'
end

group :development do
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-sass'
  gem 'guard-coffeescript'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'launchy'
  gem 'spork'
  gem 'awesome_print'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'cane', :git => 'git://github.com/square/cane.git'
  gem 'simplecov', :require => false
  gem 'flay', :require => false
  gem "rails_best_practices", :require => false
  gem 'email_spec'
end

group :production do
  gem 'newrelic_rpm'
end
