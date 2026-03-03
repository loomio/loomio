require 'test_helper'

class Api::V1::MentionsControllerTest < ActionController::TestCase
  test "returns redirect when signed out" do
    discussion = discussions(:discussion)

    get :index, params: { discussion_id: discussion.id }
    assert_response :redirect
  end

  test "returns something when signed in" do
    user = users(:admin)
    discussion = discussions(:discussion)

    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success
  end

  test "returns groups" do
    user = users(:admin)
    group = groups(:group)
    discussion = discussions(:discussion)

    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    assert_includes handles, group.handle
  end

  test "returns no group if not allowed to announce" do
    user = users(:user)
    # Create a new group without fixture memberships
    group = Group.create!(
      name: "Private Group",
      handle: "private-group",
      members_can_announce: false
    )
    group.add_member! user

    discussion = DiscussionService.create(params: { title: "Mentions #{SecureRandom.hex(4)}", group_id: group.id }, actor: user)

    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    refute_includes handles, group.handle
  end

  test "returns users" do
    admin = users(:admin)
    user = users(:user)

    # Create a user that is NOT a member
    other_user = User.create!(
      name: "Other User",
      email: "othermentions@example.com",
      username: "othermentions",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    discussion = discussions(:discussion)

    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }

    assert_includes handles, user.username
    assert_includes handles, admin.username
    refute_includes handles, other_user.username
  end

  test "returns filtered results" do
    # Create users with specific names for filtering
    filtered_user = User.create!(
      name: "aaidan",
      email: "aaidan@example.com",
      username: "aaidan",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    search_user = User.create!(
      name: "frank",
      email: "frank@example.com",
      username: "frank",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    group = groups(:group)
    group.add_member! filtered_user
    group.add_member! search_user

    discussion = DiscussionService.create(params: { title: "Filter #{SecureRandom.hex(4)}", group_id: group.id }, actor: filtered_user)

    sign_in search_user
    get :index, params: { discussion_id: discussion.id, q: 'aa' }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }

    assert_equal 1, handles.length
    assert_includes handles, filtered_user.username
    refute_includes handles, search_user.username
  end
end
