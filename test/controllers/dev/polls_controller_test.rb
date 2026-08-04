require 'test_helper'

class Dev::PollsControllerTest < ActionController::TestCase
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
