require 'test_helper'

class Api::V1::TopicMoveAccessTest < ActionController::TestCase
  tests Api::V1::TopicsController

  setup do
    @topic = topics(:discussion_topic)
    @destination = groups(:subgroup)
    @admin = users(:admin)
  end

  test 'a mover can preview the participation loss without receiving user identities' do
    sign_in @admin

    get :move_access, params: {id: @topic.id, group_id: @destination.id}

    assert_response :success
    assert_equal({'members_losing_access_count' => 7, 'can_retain_members_as_guests' => true}, response.parsed_body)
    assert_equal groups(:group).id, @topic.reload.group_id
  end

  test 'members guests and instance admins cannot preview a move they cannot perform' do
    %i[member_normal guest_normal former_guest_loud inactive_guest_loud alien server_admin].each do |role|
      sign_in users(role)
      get :move_access, params: {id: @topic.id, group_id: @destination.id}
      assert_response :forbidden, role.to_s
      refute response.parsed_body.key?('members_losing_access_count'), role.to_s
    end
  end

  test 'thread admins cannot preview an unauthorized destination' do
    sign_in users(:guest_admin_normal)
    get :move_access, params: {id: @topic.id, group_id: @destination.id}
    assert_response :forbidden
  end

  test 'retention permission is checked again when moving' do
    sign_in @admin
    get :move_access, params: {id: @topic.id, group_id: @destination.id}
    assert_response :success
    assert response.parsed_body['can_retain_members_as_guests']

    @destination.update!(members_can_add_guests: false)
    memberships(:admin_subgroup_membership).update!(admin: false)
    patch :move, params: {id: @topic.id, group_id: @destination.id, retain_members_as_guests: true}

    assert_response :forbidden
    assert_equal groups(:group).id, @topic.reload.group_id
    refute topic_readers(:reader_normal_reader).reload.guest?
  end

  test 'the move retains current members rather than trusting the earlier preview' do
    sign_in @admin
    get :move_access, params: {id: @topic.id, group_id: @destination.id}
    assert_response :success
    groups(:group).add_member!(users(:alien))

    assert_no_difference -> { Notification.count } do
      patch :move, params: {id: @topic.id, group_id: @destination.id, retain_members_as_guests: true}
    end

    assert_response :success
    assert @topic.reload.topic_readers.guests.exists?(user: users(:alien))
    assert users(:alien).can?(:create, Comment.new(parent: @topic.topicable))
  end

  test 'unknown move preview destinations are not treated as direct threads' do
    sign_in @admin
    get :move_access, params: {id: @topic.id, group_id: -1}
    assert_response :not_found
    assert_equal groups(:group).id, @topic.reload.group_id
  end

  test 'direct conversion preview and submission retain unparticipating guests' do
    sign_in @admin
    get :move_access, params: {id: @topic.id, make_direct: true}
    assert_response :success
    assert_equal({'members_losing_access_count' => 14, 'can_retain_members_as_guests' => true}, response.parsed_body)

    assert_no_difference -> { Notification.count } do
      patch :move, params: {id: @topic.id, make_direct: true, retain_members_as_guests: true}
    end

    assert_response :success
    assert_nil @topic.reload.group_id
    assert_nil topic_readers(:guest_normal_reader).reload.revoked_at
    assert users(:guest_normal).can?(:create, Comment.new(parent: @topic.topicable))
  end

  test 'direct retention recalculates access after preview without reviving revoked guests' do
    sign_in @admin
    get :move_access, params: {id: @topic.id, make_direct: true}
    assert_response :success
    reader = topic_readers(:guest_normal_reader)
    reader.update!(revoked_at: Time.current, revoker_id: @admin.id)

    patch :move, params: {id: @topic.id, make_direct: true, retain_members_as_guests: true}

    assert_response :success
    assert reader.reload.revoked_at
    refute @topic.reload.members.exists?(reader.user_id)
  end

  test 'ordinary members cannot preview or execute direct guest retention' do
    sign_in users(:member_normal)
    get :move_access, params: {id: @topic.id, make_direct: true}
    assert_response :forbidden
    patch :move, params: {id: @topic.id, make_direct: true, retain_members_as_guests: true}
    assert_response :forbidden
    assert_equal groups(:group).id, @topic.reload.group_id
  end
end
