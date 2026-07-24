require "test_helper"

class Api::V1::BootControllerTest < ActionController::TestCase
  test "version is explicitly available when signed out" do
    get :version, params: {version: "0.0.0"}, format: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal Version.current, payload.fetch("version")
    assert payload.fetch("reload")
  end
end
