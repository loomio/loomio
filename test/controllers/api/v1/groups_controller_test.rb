require "test_helper"

class Api::V1::GroupsControllerTest < ActionController::TestCase

  def setup
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @subgroup = groups(:subgroup)
    @another_group = groups(:another_group)
    @public_group = groups(:public_group)
  end

  # Index tests
  test "index returns groups by xids for authorized user" do
    sign_in @user
    @group.add_member!(@user)
    @subgroup.add_member!(@user)

    get :index, params: { xids: [@group, @subgroup].map(&:id).join('x') }

    assert_response :success
    json = JSON.parse(response.body)
    returned_ids = json['groups'].map { |h| h['id'] }

    assert_includes returned_ids, @group.id
    assert_includes returned_ids, @subgroup.id
  end

  test "index filters groups based on user permissions" do
    sign_in @another_user

    get :index, params: { xids: [@group, @another_group, @public_group].map(&:id).join('x') }

    assert_response :success
    json = JSON.parse(response.body)
    returned_ids = json['groups'].map { |h| h['id'] }

    assert_includes returned_ids, @public_group.id
  end

  # Show tests - signed in member
  test "show returns group json for member" do
    sign_in @user
    @group.add_member!(@user)

    get :show, params: { id: @group.id }, format: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert json['groups'].present?
    group_data = json['groups'][0]
    assert_equal @group.id, group_data['id']
    assert_equal @group.name, group_data['name']
  end

  test "show returns parent group information for subgroup" do
    sign_in @user
    @subgroup.add_member!(@user)

    get :show, params: { id: @subgroup.id }, format: :json

    assert_response :success
    json = JSON.parse(response.body)

    group_ids = json['groups'].map { |g| g['id'] }
    parent_ids = json['parent_groups'] ? json['parent_groups'].map { |g| g['id'] } : []
    all_ids = group_ids.concat(parent_ids)

    assert_includes all_ids, @subgroup.id
  end

  test "show returns public group when logged out" do
    get :show, params: { id: @public_group.id }, format: :json

    assert_response :success
    json = JSON.parse(response.body)
    group_ids = json['groups'].map { |g| g['id'] }

    assert_includes group_ids, @public_group.id
  end

  test "show returns 403 for private group when logged out" do
    private_group = Group.create!(
      name: 'Private Group',
      handle: 'privategroup',
      is_visible_to_public: false,
      group_privacy: 'secret'
    )

    get :show, params: { id: private_group.id }, format: :json

    assert_response 403
  end

  # Create tests
  test "create creates a group" do
    sign_in @user

    assert_difference 'Group.count', 1 do
      post :create, params: {
        group: {
          name: "New Group",
          handle: "newgroup",
          description: "A new group"
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    group_data = json['groups'][0]
    assert_equal "New Group", group_data['name']
    assert_equal "newgroup", group_data['handle']
  end

  test "create creates a group and adds creator as admin" do
    sign_in @user

    post :create, params: {
      group: {
        name: "Admin Test Group",
        handle: "admintestgroup",
        description: "Testing admin creation"
      }
    }

    assert_response :success
    json = JSON.parse(response.body)
    group_data = json['groups'][0]

    # Verify creator is in memberships and is an admin
    assert_equal 1, json['memberships'].length
    assert_equal true, json['memberships'][0]['admin']
  end

  # Update tests
  test "update changes group attributes" do
    sign_in @user
    @group.add_admin!(@user)

    put :update, params: {
      id: @group.id,
      group: {
        name: "Updated Group Name"
      }
    }

    assert_response :success
    @group.reload
    assert_equal "Updated Group Name", @group.name
  end

  test "update without admin privilege returns 403" do
    sign_in @another_user
    @group.add_member!(@another_user)

    put :update, params: {
      id: @group.id,
      group: {
        name: "New Name"
      }
    }

    assert_response 403
  end

  test "update group privacy settings" do
    sign_in @user
    @group.add_admin!(@user)

    put :update, params: {
      id: @group.id,
      group: {
        group_privacy: "open",
        is_visible_to_public: true
      }
    }

    assert_response :success
    @group.reload
    assert_equal "open", @group.group_privacy
  end

end
