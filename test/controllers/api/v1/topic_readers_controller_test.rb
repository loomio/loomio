require 'test_helper'

class Api::V1::TopicReadersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    ActionMailer::Base.deliveries.clear
  end

  test "index serializes the filtered collection" do
    @discussion.topic.add_guest!(@alien, @admin)
    sign_in @admin

    get :index, params: { topic_id: @discussion.topic_id }

    assert_response :success
    reader_ids = JSON.parse(response.body).fetch('topic_readers').pluck('id')
    assert_includes reader_ids, TopicReader.find_by!(topic: @discussion.topic, user: @alien).id
  end

  test "index pages active readers newest first and counts matching readers" do
    topic = @discussion.topic
    topic.add_guest!(@alien, @admin)
    newest = TopicReader.find_by!(topic: topic, user: @alien)
    sign_in @admin

    get :index, params: {topic_id: topic.id, active_only: 1, per: 1, from: 0}
    first = JSON.parse(response.body)
    assert_response :success
    assert_equal newest.id, first.fetch('topic_readers').first.fetch('id')
    assert_operator first.fetch('meta').fetch('total'), :>, 1

    newest.update!(revoked_at: Time.current, revoker_id: @admin.id)
    get :index, params: {topic_id: topic.id, active_only: 1, per: 1, from: 0}
    active = JSON.parse(response.body)
    assert_equal first.fetch('meta').fetch('total') - 1, active.fetch('meta').fetch('total')
    assert_not_equal newest.id, active.fetch('topic_readers').first.fetch('id')
  end

  test "index does not reveal private thread members to an unrelated user" do
    sign_in @alien

    get :index, params: {topic_id: @discussion.topic_id, active_only: 1, per: 50}

    assert_response :forbidden
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
