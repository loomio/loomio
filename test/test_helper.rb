ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "minitest/mock"
require_relative "./reset_database_helper"

# Minitest 6 parallelises by default (10 threads) which causes PG deadlocks
# against the shared test DB. Force single-threaded execution.
Minitest.parallel_executor = Minitest::Parallel::Executor.new(1)

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

# Migration tests invoke migrations directly; keep their progress output out of test results.
ActiveRecord::Migration.verbose = false


module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
    include ActiveSupport::Testing::TimeHelpers
    include ActiveJob::TestHelper

    class_attribute :jobs_inline, default: false
    class_attribute :jobs_inline_names, default: []

    def self.inline_jobs(*test_names)
      if test_names.empty?
        self.jobs_inline = true
      else
        self.jobs_inline_names += test_names.map { |test_name| "test_#{test_name.gsub(/\s+/, '_')}" }
      end
    end


    # Clean stale data from previous test runs (e.g. e2e tests, interrupted runs)
    ResetDatabaseHelper.reset_database

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all


    def create_push_subscription(user:, session: nil, **attributes)
      session ||= user.sessions.create!(user_agent: "test browser", ip_address: "127.0.0.1")
      PushSubscription.create!(session: session, **attributes)
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

    def assert_no_record_cache_fallbacks
      fallbacks = []
      subscriber = ActiveSupport::Notifications.subscribe('record_cache.fallback') do |_name, _started, _finished, _id, payload|
        fallbacks << payload
      end

      yield

      assert_empty fallbacks.map { |payload| "#{payload[:keys].join('.')}[#{payload[:id]}]" }
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    end


    # Setup common stubs before each test
    setup do
      jobs_inline_for_test = jobs_inline || jobs_inline_names.include?(name)
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = jobs_inline_for_test
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = jobs_inline_for_test
      ActionMailer::Base.deliveries.clear
      ThrottleService.reset!('hour')
      ThrottleService.reset!('day')

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

    teardown do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
      clear_enqueued_jobs
      clear_performed_jobs
    end


  end
end

# Controller test helpers
module ActionController
  class TestCase
    setup do
      Current.reset
    end

    teardown do
      Current.reset
    end

    def sign_in(user)
      session_record = user.sessions.create!(user_agent: 'test', ip_address: '127.0.0.1')
      cookies.signed[:session_id] = session_record.id
      Current.session = session_record
    end

    def sign_out(_user = nil)
      Current.session&.destroy
      Current.reset
      cookies.delete(:session_id)
    end
  end
end
