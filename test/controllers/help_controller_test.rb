require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  test "api help documents thread reads" do
    sign_in users(:user)

    get :api2

    assert_response :success
    assert_includes response.body, "/api/b2/threads"
    assert_includes response.body, "/markdown"
    assert_includes response.body, "Select a group for example commands"
  end

  test "api help hides the group selector when a group is selected" do
    user = users(:user)
    sign_in user

    get :api2, params: { group_id: 123 }

    assert_response :success
    refute_includes response.body, "Select a group for example commands"
  end

end
