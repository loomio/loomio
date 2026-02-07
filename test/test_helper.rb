ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

# Configure Sidekiq for testing
require 'sidekiq/testing'
Sidekiq::Testing.inline!
Sidekiq.logger.level = Logger::ERROR

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include ActiveSupport::Testing::TimeHelpers

    # Helper to create a discussion with proper setup
    def create_discussion(**args)
      discussion = Discussion.new({
        title: "Test Discussion",
        description: "<p>A test discussion</p>",
        description_format: "html",
        private: true
      }.merge(args))
      
      # Set defaults if not provided
      discussion.author ||= users(:discussion_author)
      discussion.group ||= groups(:test_group)
      
      # Ensure author is a member of the group
      unless discussion.group.members.include?(discussion.author)
        discussion.group.add_member!(discussion.author)
      end
      
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      discussion
    end

    # Email helper methods
    def emails_sent_to(address)
      ActionMailer::Base.deliveries.filter { |email| Array(email.to).include?(address) }
    end

    def last_email
      ActionMailer::Base.deliveries.last
    end

    def last_email_html_body
      last_email.parts[1].body
    end

    # Clean stale data from previous test runs (e.g. e2e tests, interrupted runs)
    ActiveRecord::Base.connection.execute("DELETE FROM partition_sequences")
    ActiveRecord::Base.connection.execute("DELETE FROM versions")

    # Setup common stubs before each test
    setup do
      ActionMailer::Base.deliveries.clear
      
      # Stub external API calls
      WebMock.stub_request(:get, /\.chargifypay.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:put, /\.chargifypay.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:delete, /\.chargifypay.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:get, /\.chargify.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:put, /\.chargify.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:delete, /\.chargify.com/).
        to_return(status: 200, body: '{"subscription":{"product":{"handle":"test-handle"}}}', headers: {})
      WebMock.stub_request(:get, /slack.com\/api/).
        to_return(status: 200, body: '{"ok": true}')
      WebMock.stub_request(:post, /graph.facebook.com/).
        to_return(status: 200)
      WebMock.stub_request(:post, /api.cognitive.microsoft.com/).
        to_return(status: 200)
      WebMock.stub_request(:get, /api.microsofttranslator.com/).
        to_return(status: 200)
      WebMock.stub_request(:post, /outlook.office.com/).
        to_return(status: 200)
      WebMock.stub_request(:head, /www.gravatar.com/).
        to_return(status: 200, body: "stubbed response", headers: {})
    end
  end
end

# Controller test helpers
module ActionController
  class TestCase
    include Devise::Test::ControllerHelpers
  end
end
