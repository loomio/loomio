require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    sign_in @admin
  end

  test "index redirects unauthenticated and non-admin users" do
    sign_out
    get :index
    assert_redirected_to dashboard_path

    sign_in @user
    get :index
    assert_redirected_to dashboard_path
  end

  test "admin can search users from the filter bar" do
    get :index, params: { search: @user.email, page: 1, commit: "Search" }

    assert_response :success
    assert_includes response.body, @user.name
    refute_includes response.body, users(:alien).email
    assert_operator response.body.index("Search users"), :<, response.body.index("admin-table")
    assert_includes response.body, 'list="admin-user-locales"'
    assert_includes response.body, '<datalist id="admin-user-locales">'
    assert_includes response.body, '<option value="en">'
    refute_includes response.body, 'name="time_zone"'
    document = Nokogiri::HTML(response.body)
    assert_equal ["Name", "Email", "Created", "Last sign-in", "Groups", "Deactivated", "Verified", "Locale", "Timezone"], document.css(".admin-table thead th").map { |header| header.text.strip }
    assert_equal 9, document.css(".admin-table tbody tr").first.css("td").size
    refute_includes response.body, ">Edit</a>"
  end

  test "show renders memberships with a missing group" do
    membership = memberships(:user_membership)
    missing_group_id = Group.maximum(:id) + 100
    membership.update_columns(group_id: missing_group_id)

    get :show, params: { id: @user.id }

    assert_response :success
    assert_includes response.body, "Missing group ##{missing_group_id}"
  end

  test "show uses Sign in as wording and native confirmation" do
    get :show, params: { id: @user.id }

    assert_response :success
    assert_includes response.body, "Sign in as #{@user.name}"
    assert_includes response.body, 'data-confirm="Create a one-time sign-in link'
    assert_includes response.body, 'class="admin-operation-list"'
    assert_includes response.body, 'class="admin-panel admin-panel--operations"'
    assert_includes response.body, "Email address of account to keep"
    assert_includes response.body, "Merge into account"
    assert_includes response.body, "The destination account&#39;s email and sign-in details will be kept"
    assert_includes response.body, "This cannot be undone"
  end

  test "show never renders authentication secrets" do
    get :show, params: { id: @user.id }

    assert_response :success
    %i[password_digest unsubscribe_token email_api_key secret_token api_key].each do |attribute|
      refute_includes response.body, @user.public_send(attribute), "rendered #{attribute}"
      refute_includes response.body, attribute.to_s.humanize, "rendered the #{attribute} label"
    end
  end

  test "show groups locale with account fields and timestamps with diagnostics" do
    get :show, params: { id: @user.id }

    account = response.body.index("<h2>Account</h2>")
    diagnostics = response.body.index("<h2>Diagnostics</h2>")
    locale = response.body.index("<dt>Locale</dt>")
    created_at = response.body.index("<dt>Created at</dt>")
    updated_at = response.body.index("<dt>Updated at</dt>")

    assert account < locale && locale < diagnostics
    assert diagnostics < created_at
    assert diagnostics < updated_at
  end

  test "admin can edit and update permitted user attributes" do
    get :edit, params: { id: @user.id }
    assert_response :success
    assert_includes response.body, "System admin"
    refute_includes response.body, "Instance administrator"

    put :update, params: { id: @user.id, user: { name: "Updated User", is_admin: true } }

    assert_redirected_to admin_user_path(@user)
    assert_equal "Updated User", @user.reload.name
    assert @user.is_admin?
  end

  test "user update rejects unpermitted attributes" do
    assert_raises(ActionController::UnpermittedParameters) do
      put :update, params: { id: @user.id, user: { time_zone: "UTC" } }
    end

    refute_equal "UTC", @user.reload.time_zone
  end

  test "user update shows validation errors and recommends account merge for a duplicate email" do
    original_email = @user.email

    put :update, params: { id: @user.id, user: { email: users(:member).email } }

    assert_response :unprocessable_entity
    assert_equal original_email, @user.reload.email
    assert_includes response.body, "Email has already been taken"
    assert_includes response.body, "That email belongs to another account"
    assert_includes response.body, %(href="#{admin_user_path(@user)}#merge-user")
  end

  test "admin can create a one-time sign-in link" do
    assert_difference -> { @user.login_tokens.count }, 1 do
      post :login_as, params: { id: @user.id }
    end

    assert_response :success
    assert_includes response.body, "Sign in as #{@user.name}"
    assert_includes response.body, "One-time login link"
  end

  test "non-admin cannot create a one-time sign-in link" do
    sign_out
    sign_in users(:member)

    assert_no_difference -> { @user.login_tokens.count } do
      post :login_as, params: { id: @user.id }
    end

    assert_redirected_to dashboard_path
  end

  test "sign-in link action is not routable with GET" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path(login_as_admin_user_path(@user), method: :get)
    end
  end

  test "admin can schedule account operations" do
    destination = users(:member)

    assert_enqueued_with(job: MigrateUserWorker, args: [@user.id, destination.id]) do
      post :merge, params: { id: @user.id, destination_email: destination.email }
    end
    assert_redirected_to admin_user_path(destination)

    assert_enqueued_with(job: RedactUserWorker, args: [@user.id, @admin.id]) do
      put :redact, params: { id: @user.id }
    end
    assert_enqueued_with(job: DeactivateUserWorker, args: [@user.id, @admin.id]) do
      put :deactivate, params: { id: @user.id }
    end
    assert_enqueued_with(job: ReactivateUserWorker, args: [@user.id]) do
      put :reactivate, params: { id: @user.id }
    end
    assert_enqueued_with(job: DestroyUserWorker, args: [@user.id]) do
      delete :delete_spam, params: { id: @user.id }
    end
  end

  test "admin can only delete an identity belonging to the selected user" do
    identity = @user.identities.create!(identity_type: "test", uid: "user-identity")
    other_identity = users(:member).identities.create!(identity_type: "test", uid: "other-identity")

    post :delete_identity, params: { id: @user.id, identity_id: identity.id }
    refute Identity.exists?(identity.id)

    post :delete_identity, params: { id: @user.id, identity_id: other_identity.id }
    assert_response :not_found
    assert Identity.exists?(other_identity.id)
  end
end
