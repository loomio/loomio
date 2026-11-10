require 'test_helper'

class Dev::PollsControllerTest < ActionController::TestCase
  inline_jobs
  tests Dev::PollsController

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
    ActionMailer::Base.deliveries.clear
  end

  test "poll reminder email preview delivers without a background worker" do
    get :test_poll_scenario, params: {
      poll_type: 'dot_vote',
      scenario: 'poll_reminder',
      format: 'email'
    }

    assert_response :success
    refute_includes response.body, "no emails sent"
    assert_includes response.body, "is reminding you to vote"
  end
end

class Dev::PollScenarioSessionsTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  test "rebuilding a scenario replaces the browser's previous session" do
    get '/dev/polls/test_discussion'
    assert_response :redirect
    get URI(response.location).request_uri
    assert_response :success

    get '/dev/polls/test_discussion', params: { time_zone: 'America/Los_Angeles' }
    assert_response :redirect
    get URI(response.location).request_uri
    assert_response :success
    assert_equal 'America/Los_Angeles', Session.active.sole.user.time_zone

    get '/api/v1/profile/email_api_key', as: :json
    assert_response :success
  end
end
