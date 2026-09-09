require 'test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
  end

  test "index redirects unauthenticated users to dashboard" do
    get :index

    assert_redirected_to dashboard_path
  end

  test "index redirects non-admin users to dashboard" do
    sign_in users(:user)

    get :index

    assert_redirected_to dashboard_path
  end

  test "admin can search groups from the filter bar" do
    sign_in @admin

    get :index, params: { search: @group.handle, page: 1, commit: "Search" }

    assert_response :success
    assert_includes response.body, @group.name
    refute_includes response.body, groups(:alien_group).name
    assert_operator response.body.index("Search groups"), :<, response.body.index("admin-table")
    assert_includes response.body, 'data-confirm="Schedule the selected trial groups'
  end

  test "admin can show and edit a group" do
    sign_in @admin

    get :show, params: { id: @group.id }
    assert_response :success
    assert_includes response.body, "Group stats"
    assert_includes response.body, "Add admin"
    refute_includes response.body, "Add coordinator"
    assert_includes response.body, 'class="admin-table admin-table--compact"'
    assert_includes response.body, 'class="admin-operation-list"'
    assert_includes response.body, 'class="admin-panel admin-panel--operations"'
    assert_includes response.body, "Parent group ID or key"
    assert_includes response.body, "Warn then delete"
    assert_includes response.body, "Delete immediately"
    assert_includes response.body, "Discard without warning"
    assert_includes response.body, "all of its subgroups"
    assert_includes response.body, "memberships and membership requests"
    assert_includes response.body, "User accounts and subscriptions are retained"

    get :edit, params: { id: @group.id }
    assert_response :success
    assert_includes response.body, "Save group"
  end

  test "admin can update permitted group attributes" do
    sign_in @admin

    put :update, params: { id: @group.id, group: { membership_granted_upon: "invitation" } }

    assert_redirected_to admin_group_path(@group)
    assert_equal "invitation", @group.reload.membership_granted_upon
  end

  test "group update rejects unpermitted attributes" do
    sign_in @admin

    assert_raises(ActionController::UnpermittedParameters) do
      put :update, params: { id: @group.id, group: { name: "Not permitted" } }
    end

    refute_equal "Not permitted", @group.reload.name
  end

  test "group update shows validation errors" do
    sign_in @admin
    original_handle = @group.handle
    privacy_change_committed = false
    privacy_change = Object.new
    privacy_change.define_singleton_method(:commit!) { privacy_change_committed = true }

    GroupService::PrivacyChange.stub(:new, privacy_change) do
      put :update, params: { id: @group.id, group: { handle: groups(:alien_group).handle } }
    end

    assert_response :unprocessable_entity
    assert_equal original_handle, @group.reload.handle
    refute privacy_change_committed
    assert_includes response.body, "Group could not be updated"
    assert_includes response.body, "Handle has already been taken"
  end

  test "admin can add and remove a group admin" do
    sign_in @admin
    membership = memberships(:user_membership)

    post :add_admin, params: { membership_id: membership.id }
    assert membership.reload.admin?
    assert_redirected_to admin_group_path(@group)

    post :remove_admin, params: { membership_id: membership.id }
    refute membership.reload.admin?
    assert_redirected_to admin_group_path(@group)
  end

  test "admin can import and send a JSON group export" do
    sign_in @admin
    recipient_email = "records@example.com"

    get :import
    assert_response :success

    assert_enqueued_with(job: ImportGroupWorker, args: ["https://example.com/group.json"]) do
      post :import_json, params: { url: "https://example.com/group.json" }
    end

    assert_enqueued_with(job: GroupExportWorker, args: [@group.all_groups.pluck(:id), @group.name, @admin.id, recipient_email]) do
      post :export_group, params: { id: @group.id, email: recipient_email, export_format: "json" }
    end
    assert_equal "JSON group export will be sent to #{recipient_email}", flash[:notice]
  end

  test "admin can send a CSV export for a discarded group" do
    sign_in @admin
    @group.discard!(actor: @admin)
    recipient_email = "records@example.com"

    assert_enqueued_with(job: GroupExportCsvWorker, args: [@group.id, @admin.id, recipient_email]) do
      post :export_group, params: { id: @group.id, email: recipient_email, export_format: "csv" }
    end

    assert_redirected_to admin_group_path(@group)
    assert_equal "CSV group export will be sent to #{recipient_email}", flash[:notice]

    get :show, params: { id: @group.id }
    assert_includes response.body, "Restore group"
    assert_includes response.body, "Send data export to email"
    assert_includes response.body, "JSON"
    assert_includes response.body, "CSV"
  end

  test "admin group export rejects invalid email and format" do
    sign_in @admin

    assert_no_enqueued_jobs(only: [ GroupExportWorker, GroupExportCsvWorker ]) do
      post :export_group, params: { id: @group.id, email: "invalid", export_format: "json" }
    end
    assert_equal "Enter a valid export recipient email", flash[:alert]

    assert_no_enqueued_jobs(only: [ GroupExportWorker, GroupExportCsvWorker ]) do
      post :export_group, params: { id: @group.id, email: "records@example.com", export_format: "pdf" }
    end
    assert_equal "Select JSON or CSV export format", flash[:alert]
  end

  test "non-admin cannot send a group export" do
    sign_in users(:user)

    assert_no_enqueued_jobs(only: [ GroupExportWorker, GroupExportCsvWorker ]) do
      post :export_group, params: { id: @group.id, email: "records@example.com", export_format: "json" }
    end

    assert_redirected_to dashboard_path
  end

  test "admin can discard without warning and restore a group" do
    sign_in @admin
    post :discard, params: { id: @group.id }
    assert @group.reload.discarded?
    assert_equal @admin.id, @group.discarded_by
    assert_equal "Group discarded without warning", flash[:notice]

    post :undiscard, params: { id: @group.id }
    assert_nil @group.reload.discarded_at
    assert_nil @group.discarded_by
  end

  test "admin group operations call the group service" do
    sign_in @admin
    moved = false
    warned = false
    destroyed = false

    GroupService.stub(:move, ->(group:, parent:, actor:) { moved = group == @group && parent == groups(:public_group) && actor == @admin }) do
      post :move, params: { id: @group.id, parent_id: groups(:public_group).id }
    end
    assert moved

    GroupService.stub(:warn_and_discard, ->(group:, actor:) { warned = group == @group && actor == @admin }) do
      post :warn_and_discard, params: { id: @group.id }
    end
    assert warned
    assert_equal "Group administrators warned; group marked for deletion after #{AppConfig.group_deletion_grace_days} days", flash[:notice]

    GroupService.stub(:destroy, ->(group:, actor:) { destroyed = group == @group && actor == @admin }) do
      post :destroy, params: { id: @group.id }
    end
    assert destroyed
    assert_equal "Group deletion scheduled immediately", flash[:notice]
  end

  test "admin can schedule trial groups for spam deletion" do
    sign_in @admin
    subscription = Subscription.create!(owner: @admin, plan: "trial")
    @group.update!(subscription: subscription, creator: users(:user))

    assert_enqueued_with(job: DestroyUserWorker, args: [users(:user).id]) do
      post :delete_spam, params: { group_ids: [@group.id] }
    end
  end

  test "admin can render the user export report" do
    sign_in @admin

    get :export_users
    assert_response :success

    get :export_users_report, params: { group_ids: @group.id.to_s }
    assert_response :success
    assert_includes response.body, users(:user).email
  end
end
