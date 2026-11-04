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
    assert_equal ["", "Name", "Email", "Created", "Last sign-in", "Groups", "Deactivated", "Verified", "Locale", "Timezone"], document.css(".admin-table thead th").map { |header| header.text.strip }
    assert_equal 10, document.css(".admin-table tbody tr").first.css("td").size
    assert_includes response.body, "Select all users on this page"
    assert_includes response.body, "Apply to selected users"
    assert_includes response.body, "Blocks sign-in and revokes group memberships"
    assert_includes response.body, "permanently removes personal and sign-in data"
    assert_includes response.body, "Destroy / delete as spam"
    refute_includes response.body, ">Edit</a>"
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

  test "only instance administrators can clear local blocks" do
    block = EmailSuppressionService.record!(email: @user.email, reason: 'complaint', source_key: 'test:complaint')
    [users(:member), users(:alien)].each do |actor|
      sign_out
      sign_in actor
      post :clear_email_suppressions, params: { id: @user.id }
      assert_redirected_to dashboard_path
      assert_nil block.reload.cleared_at
    end
    sign_out
    post :clear_email_suppressions, params: { id: @user.id }
    assert_redirected_to dashboard_path
    assert_nil block.reload.cleared_at

    sign_in @admin
    post :clear_email_suppressions, params: { id: @user.id }
    assert_redirected_to admin_user_path(@user)
    assert_equal @admin.id, block.reload.cleared_by_id
    assert_equal 'administrator', block.clear_method
  end

  test "email provider checks are optional read only and restricted to instance administrators" do
    previous_region = ENV['SES_SUPPRESSION_REGION']
    ENV.delete('SES_SUPPRESSION_REGION')
    post :check_email_provider, params: { id: @user.id }
    assert_response :not_found
    ENV['SES_SUPPRESSION_REGION'] = 'us-east-1'
    sign_out
    sign_in users(:member)
    SesEmailSuppressionService.stub(:client, -> { raise 'must not contact SES' }) do
      post :check_email_provider, params: { id: @user.id }
      assert_redirected_to dashboard_path
    end
    sign_out
    sign_in @admin
    client = Aws::SESV2::Client.new(region: 'us-east-1', stub_responses: true)
    client.stub_responses(:get_suppressed_destination, suppressed_destination: {
      email_address: @user.email, reason: 'BOUNCE', last_update_time: Time.current
    })
    SesEmailSuppressionService.stub(:client, client) do
      assert_no_difference 'EmailSuppression.count' do
        post :check_email_provider, params: { id: @user.id }
      end
      assert_response :success
      assert_includes response.body, 'SES account suppression list entry: BOUNCE'
      assert_equal({email_address: @user.email}, client.api_requests.sole[:params])

      client.stub_responses(:get_suppressed_destination, 'NotFoundException')
      post :check_email_provider, params: { id: @user.id }
      assert_response :success
      assert_includes response.body, 'No SES account suppression found'
      client.stub_responses(:get_suppressed_destination, 'AccessDeniedException')
      post :check_email_provider, params: { id: @user.id }
      assert_response :success
      assert_includes response.body, 'could not be checked'
    end
  ensure
    previous_region.nil? ? ENV.delete('SES_SUPPRESSION_REGION') : ENV['SES_SUPPRESSION_REGION'] = previous_region
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

  test "admin can choose the operation for selected users" do
    selected_users = [@user, users(:alien)]

    assert_enqueued_jobs 2, only: DeactivateUserWorker do
      post :bulk_action, params: { user_ids: selected_users.map(&:id), operation: "deactivate" }
    end
    deactivation_jobs = enqueued_jobs.select { |job| job[:job] == DeactivateUserWorker }
    assert_equal selected_users.map(&:id).sort, deactivation_jobs.map { |job| job[:args].first }.sort

    assert_redirected_to admin_users_path
    assert_equal "2 users scheduled for deactivation", flash[:notice]

    assert_enqueued_with(job: RedactUserWorker, args: [@user.id, @admin.id]) do
      post :bulk_action, params: { user_ids: [@user.id], operation: "redact" }
    end

    assert_enqueued_with(job: DestroyUserWorker, args: [@user.id]) do
      post :bulk_action, params: { user_ids: [@user.id], operation: "delete_spam" }
    end
  end

  test "bulk operation requires a selected user and valid action" do
    assert_no_enqueued_jobs do
      post :bulk_action, params: { operation: "deactivate" }
    end

    assert_redirected_to admin_users_path
    assert_equal "Select at least one user", flash[:alert]

    assert_no_enqueued_jobs do
      post :bulk_action, params: { user_ids: [@user.id], operation: "unknown" }
    end
    assert_equal "Select a valid bulk action", flash[:alert]
  end

  test "non-admin cannot perform bulk user operations" do
    sign_out
    sign_in users(:member)

    assert_no_enqueued_jobs do
      post :bulk_action, params: { user_ids: [@user.id], operation: "deactivate" }
    end

    assert_redirected_to dashboard_path
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
