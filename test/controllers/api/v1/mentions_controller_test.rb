require 'test_helper'

class Api::V1::MentionsControllerTest < ActionController::TestCase
  test "returns redirect when signed out" do
    topic = topics(:discussion_topic)

    get :index, params: { topic_id: topic.id }
    assert_response :redirect
  end

  test "returns something when signed in" do
    user = users(:admin)
    topic = topics(:discussion_topic)

    sign_in user
    get :index, params: { topic_id: topic.id }
    assert_response :success
  end

  test "returns groups for topic" do
    user = users(:admin)
    group = groups(:group)
    topic = topics(:discussion_topic)

    sign_in user
    get :index, params: { topic_id: topic.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    assert_includes handles, group.handle
  end

  test "returns groups for group" do
    user = users(:admin)
    group = groups(:group)

    sign_in user
    get :index, params: { group_id: group.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    assert_includes handles, group.handle
  end


  test "returns no group if not allowed to announce" do
    user = users(:user)
    group = Group.create!(
      name: "Private Group",
      handle: "private-group",
      members_can_announce: false
    )
    group.add_member! user

    discussion = DiscussionService.create(params: { title: "Mentions #{SecureRandom.hex(4)}", group_id: group.id }, actor: user)

    sign_in user
    get :index, params: { topic_id: discussion.topic_id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }
    refute_includes handles, group.handle
  end

  test "returns users for topic" do
    admin = users(:admin)
    user = users(:user)

    other_user = User.create!(
      name: "Other User",
      email: "othermentions@example.com",
      username: "othermentions",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    topic = topics(:discussion_topic)

    sign_in user
    get :index, params: { topic_id: topic.id }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }

    assert_includes handles, user.username
    assert_includes handles, admin.username
    refute_includes handles, other_user.username
  end

  test "returns filtered results" do
    filtered_user = User.create!(
      name: "aaidan",
      email: "aaidan@example.com",
      username: "aaidan",
      email_verified: true
    )

    search_user = User.create!(
      name: "frank",
      email: "frank@example.com",
      username: "frank",
      email_verified: true
    )

    group = groups(:group)
    group.add_member! filtered_user
    group.add_member! search_user

    discussion = DiscussionService.create(params: { title: "Filter #{SecureRandom.hex(4)}", group_id: group.id }, actor: filtered_user)

    sign_in search_user
    get :index, params: { topic_id: discussion.topic_id, q: 'aa' }
    assert_response :success

    rows = JSON.parse(response.body)
    handles = rows.map { |row| row['handle'] }

    assert_equal 1, handles.length
    assert_includes handles, filtered_user.username
    refute_includes handles, search_user.username
  end
end
