require 'test_helper'

class Api::V1::MentionsControllerTest < ActionController::TestCase
  test "returns redirect when signed out" do
    discussion = discussions(:test_discussion)

    get :index, params: { discussion_id: discussion.id }
    assert_response :redirect
  end

  test "returns something when signed in" do
    user = users(:discussion_author)
    discussion = discussions(:test_discussion)

    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success
  end

  test "returns groups" do
    user = users(:discussion_author)
    group = groups(:test_group)
    discussion = discussions(:test_discussion)
    
    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success
    
    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    assert_includes handles, group.handle
  end

  test "returns no group if not allowed to announce" do
    user = users(:normal_user)
    # Create a new group without fixture memberships
    group = Group.create!(
      name: "Private Group",
      handle: "private-group",
      members_can_announce: false
    )
    group.add_member! user
    
    discussion = create_discussion(author: user, group: group)
    
    sign_in user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success
    
    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    refute_includes handles, group.handle
  end

  test "returns users" do
    user = users(:discussion_author)
    another_user = users(:another_user)

    # Create a user that is NOT a member
    other_user = User.create!(
      name: "Other User",
      email: "othermentions@example.com",
      username: "othermentions",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    discussion = discussions(:test_discussion)

    sign_in another_user
    get :index, params: { discussion_id: discussion.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }

    assert_includes handles, another_user.username
    assert_includes handles, user.username
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
    
    group = groups(:test_group)
    group.add_member! filtered_user
    group.add_member! search_user
    
    discussion = create_discussion(author: filtered_user, group: group)
    
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
