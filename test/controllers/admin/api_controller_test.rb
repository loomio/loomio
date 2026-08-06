require "test_helper"

class Admin::ApiControllerTest < ActionController::TestCase
  test "API documentation redirects unauthenticated users" do
    get :show

    assert_redirected_to dashboard_path
  end

  test "API documentation redirects non-admin users" do
    sign_in users(:user)

    get :show

    assert_redirected_to dashboard_path
  end

  test "admin can view B3 API documentation in the admin layout" do
    sign_in users(:admin)

    with_b3_api_key(nil) { get :show }

    assert_response :success
    assert_includes response.body, "B3 API"
    assert_includes response.body, "/api/b3/users"
    assert_includes response.body, admin_api_path
    assert_includes response.body, "Loomio admin"
    assert_includes response.body, "Disabled"
    assert_includes response.body, "B3_API_KEY is not set"
    assert_includes response.body, "deploy/env"
  end

  test "API documentation reports a configured key without displaying it" do
    sign_in users(:admin)
    api_key = "a-valid-api-key-that-must-stay-secret"

    with_b3_api_key(api_key) { get :show }

    assert_response :success
    assert_includes response.body, "Enabled"
    assert_includes response.body, "B3_API_KEY is set"
    refute_includes response.body, api_key
  end

  test "API documentation reports a key that is too short" do
    sign_in users(:admin)

    with_b3_api_key("too-short") { get :show }

    assert_response :success
    assert_includes response.body, "Disabled"
    assert_includes response.body, "must be longer than 16 characters"
  end

  test "B3 API endpoints remain at their existing paths" do
    assert_routing(
      { method: "get", path: "/api/b3/users/123" },
      { controller: "api/b3/users", action: "show", id: "123", format: :json }
    )
  end

  test "old public B3 help route is removed" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/help/api3", method: :get)
    end
  end

  private

  def with_b3_api_key(value)
    original = ENV.key?("B3_API_KEY") ? ENV.fetch("B3_API_KEY") : nil
    original_set = ENV.key?("B3_API_KEY")
    value.nil? ? ENV.delete("B3_API_KEY") : ENV["B3_API_KEY"] = value
    yield
  ensure
    original_set ? ENV["B3_API_KEY"] = original : ENV.delete("B3_API_KEY")
  end
end
