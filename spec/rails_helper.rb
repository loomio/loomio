# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'

require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods

  config.before(:each) do

    stub_request(:get, /\.chargifypay.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
    stub_request(:put, /\.chargifypay.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
    stub_request(:delete, /\.chargifypay.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
    stub_request(:get, /\.chargify.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
    stub_request(:put, /\.chargify.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
    stub_request(:delete, /\.chargify.com/).
      to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})

    stub_request(:get,  /slack.com\/api/).to_return(status: 200, body: '{"ok": true}')
    stub_request(:post, /graph.facebook.com/).to_return(status: 200)
    stub_request(:post, /api.cognitive.microsoft.com/).to_return(status: 200)
    stub_request(:get,  /api.microsofttranslator.com/).to_return(status: 200)
    stub_request(:post, /outlook.office.com/).to_return(status: 200)

    stub_request(:head, /www.gravatar.com/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: "stubbed response", headers: {})
  end
end

def fixture_for(path, filetype: 'image/jpeg')
  Rack::Test::UploadedFile.new(Rails.root.join('spec','fixtures', path), filetype)
end

def described_model_name
  described_class.model_name.singular
end

def last_email
  ActionMailer::Base.deliveries.last
end

def last_email_html_body
  last_email.parts[1].body
end
