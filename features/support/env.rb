require 'cucumber/rails'
require 'email_spec'
require 'email_spec/cucumber'
require "rack_session_access/capybara"
require 'capybara/poltergeist'

Capybara.default_selector = :css
ActionController::Base.allow_rescue = false
Cucumber::Rails::Database.javascript_strategy = :truncation
Capybara.default_wait_time = 5
ENV['LOOMIO_NEW_USERS_ON_BETA'] = '1'

polter_options = {
  :phantomjs_options => ['--load-images=no'],
  js_errors: true,
  inspector: true,
  debug: false
}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, polter_options)
end

#Capybara.javascript_driver = :selenium
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist

Before do |scenario|
  stub_request(:head, /gravatar.com/).with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
  stub_request(:post, /api.cognitive.microsoft.com/).to_return(status: 200, body: "", headers: {})
  stub_request(:get,  /api.microsofttranslator.com/).to_return(status: 200, body: "", headers: {})
end
