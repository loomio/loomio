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
    assert_includes response.body, "Their content will be retained"
    assert_includes response.body, "all of its subgroups"
    assert_includes response.body, "memberships and membership requests"
    assert_includes response.body, "User accounts and subscriptions are not deleted"

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

  test "admin can import and export groups" do
    sign_in @admin

    get :import
    assert_response :success

    assert_enqueued_with(job: ImportGroupWorker, args: ["https://example.com/group.json"]) do
      post :import_json, params: { url: "https://example.com/group.json" }
    end

    assert_enqueued_with(job: GroupExportWorker, args: [@group.all_groups.pluck(:id), @group.name, @admin.id]) do
      post :export_group, params: { id: @group.id }
    end
  end

  test "admin can archive and unarchive a group" do
    sign_in @admin

    post :archive, params: { id: @group.id }
    assert @group.reload.archived_at

    post :unarchive, params: { id: @group.id }
    assert_nil @group.reload.archived_at
  end

  test "admin group operations call the group service" do
    sign_in @admin
    moved = false
    destroyed_id = nil

    GroupService.stub(:move, ->(group:, parent:, actor:) { moved = group == @group && parent == groups(:public_group) && actor == @admin }) do
      post :move, params: { id: @group.id, parent_id: groups(:public_group).id }
    end
    assert moved

    GroupService.stub(:destroy_without_warning!, ->(id) { destroyed_id = id }) do
      post :delete_group, params: { id: @group.id }
    end
    assert_equal @group.id, destroyed_id
    assert_equal "Group deletion scheduled", flash[:notice]
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
