require "test_helper"

class Api::V1::Mobile::ConfigControllerTest < ActionController::TestCase
  tests Api::V1::Mobile::ConfigController

  test "advertises same-origin versioned endpoints without caching" do
    @request.host = "community.example.org"
    @request.env["HTTPS"] = "on"
    get :show

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["protocol_version"]
    assert_equal "https://community.example.org", payload["issuer"]
    assert_equal "https://community.example.org/mobile/authorize", payload["authorization_endpoint"]
    assert_equal "https://community.example.org/api/v1/mobile/token", payload["token_endpoint"]
    assert_equal "https://community.example.org/api/v1/mobile/relay-authorizations", payload["relay_authorization_endpoint"]
    assert_equal "https://community.example.org/api/v1/mobile/push-registration", payload["push_registration_endpoint"]
    assert_equal "https://community.example.org/api/v1/mobile/activity", payload["activity_endpoint"]
    assert_equal "no-store", response.headers["Cache-Control"]
  end
end
