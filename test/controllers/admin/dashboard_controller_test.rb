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
      "Enabled groups",
      "Discarded groups",
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
    assert_select '#authentication-stats tbody tr', count: 5
    assert_includes response.body, "Signed in within 30 days"
  end

  test "dashboard counts users by current credentials and latest sign-in" do
    freeze_time do
      sign_in users(:admin)
      password_digest = users(:user).password_digest
      User.update_all(password_digest: nil, current_sign_in_at: nil, last_sign_in_at: nil, last_seen_at: nil)
      PasskeyCredential.delete_all
      total = User.count
      password = users(:user)
      password.update_columns(password_digest: password_digest, current_sign_in_at: 30.days.ago)
      passkey = users(:member)
      passkey.update_columns(password_digest: '', current_sign_in_at: 1.day.ago, last_sign_in_at: 60.days.ago)
      both = users(:alien)
      both.update_columns(password_digest: password_digest, current_sign_in_at: 30.days.ago - 1.second, last_seen_at: Time.current, deactivated_at: Time.current)
      users(:subgroup_user).update_columns(current_sign_in_at: 1.hour.ago)
      [passkey, passkey, both].each_with_index do |user, index|
        user.passkey_credentials.create!(external_id: "credential-#{index}", public_key: 'public-key', user_handle: "handle-#{user.id}", name: "Passkey #{index}")
      end

      get :show

      assert_response :success
      rows = css_select('#authentication-stats tbody tr').map { |row| row.css('th, td').map(&:text) }
      assert_equal [
        ['All users', total.to_fs(:delimited), '3'],
        ['With a password', '2', '1'],
        ['With a passkey', '2', '1'],
        ['With both', '1', '0'],
        ['With neither', (total - 3).to_fs(:delimited), '1']
      ], rows
      refute_includes response.body, password_digest
      refute_includes response.body, 'public-key'
    end
  end

  test "admin root routes to the dashboard" do
    assert_routing(
      { method: "get", path: "/admin" },
      { controller: "admin/dashboard", action: "show" }
    )
  end
end
