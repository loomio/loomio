require 'test_helper'

class Api::V1::TopicReadersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = DiscussionService.create(params: { title: "TR Test #{SecureRandom.hex(4)}", group_id: @group.id }, actor: @admin)
    ActionMailer::Base.deliveries.clear
  end

  # -- make_admin --

  test "make_admin with permission makes user admin of topic" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)

    sign_in @admin
    post :make_admin, params: { id: reader.id }
    assert_response :success
    assert reader.reload.admin
  end

  test "make_admin denied for non-admin" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)

    sign_in @user
    post :make_admin, params: { id: reader.id }
    assert_response :forbidden
    assert_not reader.reload.admin
  end

  # -- remove_admin --

  test "remove_admin with permission removes admin from topic" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)
    reader.update!(admin: true)

    sign_in @admin
    post :remove_admin, params: { id: reader.id }
    assert_response :success
    assert_not reader.reload.admin
  end

  test "remove_admin denied for non-admin" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)
    reader.update!(admin: true)

    sign_in @user
    post :remove_admin, params: { id: reader.id }
    assert_response :forbidden
    assert reader.reload.admin
  end

  # -- revoke --

  test "revoke with permission revokes guest" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)
    assert reader.guest
    assert_nil reader.revoked_at

    sign_in @admin
    post :revoke, params: { id: reader.id }
    assert_response :success
    assert_not_nil reader.reload.revoked_at
  end

  test "revoke denied for non-admin" do
    @discussion.topic.add_guest!(@alien, @admin)
    reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)

    sign_in @user
    post :revoke, params: { id: reader.id }
    assert_response :forbidden
    assert_nil reader.reload.revoked_at
  end

  test "revoke denied for non-guest reader" do
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.save!
    assert_not reader.guest

    sign_in @admin
    post :revoke, params: { id: reader.id }
    assert_response :forbidden
    assert_nil reader.reload.revoked_at
  end

  # -- topic admin (not group admin) managing guests --

  test "topic admin can make guest admin" do
    # Make @user a topic admin (not group admin)
    topic_admin_reader = TopicReader.for(user: @user, topic: @discussion.topic)
    topic_admin_reader.update!(admin: true)

    @discussion.topic.add_guest!(@alien, @admin)
    guest_reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)

    sign_in @user
    post :make_admin, params: { id: guest_reader.id }
    assert_response :success
    assert guest_reader.reload.admin
  end

  test "topic admin can revoke guest" do
    topic_admin_reader = TopicReader.for(user: @user, topic: @discussion.topic)
    topic_admin_reader.update!(admin: true)

    @discussion.topic.add_guest!(@alien, @admin)
    guest_reader = TopicReader.find_by(topic: @discussion.topic, user: @alien)

    sign_in @user
    post :revoke, params: { id: guest_reader.id }
    assert_response :success
    assert_not_nil guest_reader.reload.revoked_at
  end
end
