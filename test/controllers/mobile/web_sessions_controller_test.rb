require "test_helper"

class Mobile::WebSessionsControllerTest < ActionController::TestCase
  tests Mobile::WebSessionsController

  setup do
    @user = User.create!(
      name: "Mobile User",
      username: "mobileweb#{SecureRandom.hex(4)}",
      email: "mobileweb#{SecureRandom.hex(4)}@example.com",
      email_verified: true
    )
    @device = @user.mobile_devices.create!(name: "Test iPhone", last_seen_at: Time.current)
  end

  test "consumes a ticket and creates a fresh ordinary web session" do
    ticket = Mobile::AuthenticationService.issue_web_session_ticket!(device: @device)

    assert_difference "Session.count", 1 do
      post :create, params: { ticket: ticket }
    end

    assert_response :see_other
    assert_redirected_to dashboard_path
    assert_equal @user, Current.session.user
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "no-referrer", response.headers["Referrer-Policy"]

    post :create, params: { ticket: ticket }
    assert_response :bad_request
  end

  test "rejects a ticket in the query string" do
    ticket = Mobile::AuthenticationService.issue_web_session_ticket!(device: @device)
    @request.query_string = "ticket=#{CGI.escape(ticket)}"

    post :create

    assert_response :bad_request
    assert_nil Current.session
  end
end
