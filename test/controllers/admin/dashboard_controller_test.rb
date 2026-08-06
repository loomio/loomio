require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase
  test "dashboard redirects unauthenticated users" do
    get :show

    assert_redirected_to dashboard_path
  end

  test "dashboard redirects non-admin users" do
    sign_in users(:user)

    get :show

    assert_redirected_to dashboard_path
  end

  test "admin dashboard shows twelve operational stats" do
    sign_in users(:admin)

    get :show

    assert_response :success
    labels = [
      "Total users",
      "Active users",
      "Deactivated users",
      "Users joined in 30 days",
      "Total groups",
      "Active groups",
      "Archived groups",
      "Groups created in 30 days",
      "Active memberships",
      "Discussions",
      "Polls",
      "Comments"
    ]
    labels.each { |label| assert_includes response.body, label }
    assert_equal 12, response.body.scan("<strong>").size
    assert_includes response.body, ">Dashboard</a>"
    refute_includes response.body, "Subscriptions"
  end

  test "admin root routes to the dashboard" do
    assert_routing(
      { method: "get", path: "/admin" },
      { controller: "admin/dashboard", action: "show" }
    )
  end
end
