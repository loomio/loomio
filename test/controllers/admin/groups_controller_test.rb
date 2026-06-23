require 'test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase
  test "index redirects unauthenticated users to dashboard" do
    get :index

    assert_redirected_to dashboard_path
  end

  test "index redirects non-admin users to dashboard" do
    sign_in users(:user)

    get :index

    assert_redirected_to dashboard_path
  end
end
