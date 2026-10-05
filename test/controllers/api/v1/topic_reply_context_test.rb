require 'test_helper'

class Api::V1::TopicReplyContextTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  setup do
    @discussion = topics(:discussion_topic).topicable
    @actor = users(:admin)
    @first = create_comment(@discussion, 'First comment')
    @parent = create_comment(@first, 'Actual parent comment')
    @unrelated = create_comment(@first, 'Unrelated sibling')
    @reply = create_comment(@parent, 'Newest reply')
    @reply_item = @reply.created_topic_item
  end

  test 'a one-item page serializes actual parent context without changing the display hierarchy or cache fallbacks' do
    sign_in users(:member_normal)
    assert_no_record_cache_fallbacks do
      get :index, params: {topic_id: @discussion.topic_id, from: @reply_item.sequence_id, per: 1}
    end
    assert_response :success
    json = response.parsed_body
    assert_equal [@reply_item.id], json.fetch('topic_items').pluck('id')
    reply = json.fetch('topic_items').first
    assert_equal @first.created_topic_item.id, reply.fetch('parent_id')
    assert_equal @parent.created_topic_item.id, reply.fetch('reply_parent_id')
    assert_equal @parent.created_topic_item.id, @reply_item.reply_parent.id
    assert_context json, @parent
    assert_not_includes json.fetch('comments').pluck('id'), @unrelated.id
  end

  test 'unread loading and direct comment links include the actual parent' do
    reader = TopicReader.for(user: users(:member_normal), topic: @discussion.topic)
    reader.viewed!([0, @first.created_topic_item.sequence_id, @parent.created_topic_item.sequence_id,
                    @unrelated.created_topic_item.sequence_id])
    sign_in users(:member_normal)
    get :index, params: {topic_id: @discussion.topic_id, unread_or_newest: 1, per: 1}
    assert_response :success
    assert_equal [@reply_item.id], response.parsed_body.fetch('topic_items').pluck('id')
    assert_context response.parsed_body, @parent

    get :comment, params: {topic_id: @discussion.topic_id, comment_id: @reply.id}
    assert_response :success
    assert_context response.parsed_body, @parent
  end

  test 'shared realtime serialization includes reply context with no cache fallbacks' do
    data = nil
    assert_no_record_cache_fallbacks do
      data = JSON.parse(MessageChannelService.serialize_shared_models([@reply_item]).to_json)
    end
    assert_context data, @parent
  end

  test 'reply context follows a chain longer than the display depth' do
    latest = @reply
    4.times { |index| latest = create_comment(latest, "Nested reply #{index}") }
    sign_in users(:guest_normal)
    assert_no_record_cache_fallbacks do
      get :comment, params: {topic_id: @discussion.topic_id, comment_id: latest.id}
    end
    assert_response :success
    assert_context response.parsed_body, @parent
    assert_context response.parsed_body, @reply
  end

  [:alien_loud, :non_guest_loud, :former_guest_loud, :inactive_guest_loud].each do |role|
    test "private reply context is inaccessible to #{role}" do
      sign_in users(role)
      get :comment, params: {topic_id: @discussion.topic_id, comment_id: @reply.id}
      assert_not response.successful?
      assert_not_includes response.body, @parent.body
    end
  end

  test 'signed out users cannot fetch private reply context' do
    get :comment, params: {topic_id: @discussion.topic_id, comment_id: @reply.id}
    assert_response :forbidden
    assert_not_includes response.body, @parent.body
  end

  test 'public reply context is visible when signed out' do
    discussion = topics(:public_discussion_topic).topicable
    discussion.group.add_member!(@actor)
    first = create_comment(discussion, 'Public first comment')
    parent = create_comment(first, 'Public actual parent')
    reply = create_comment(parent, 'Public reply')
    get :comment, params: {topic_id: discussion.topic_id, comment_id: reply.id}
    assert_response :success
    assert_context response.parsed_body, parent
  end

  test 'direct topic reply context follows guest access' do
    discussion = topics(:direct_topic).topicable
    @actor = users(:guest_admin_normal)
    discussion.create_missing_created_topic_item!
    first = create_comment(discussion, 'Direct first comment')
    parent = create_comment(first, 'Direct actual parent')
    reply = create_comment(parent, 'Direct reply')
    sign_in users(:guest_normal)
    get :comment, params: {topic_id: discussion.topic_id, comment_id: reply.id}
    assert_response :success
    assert_context response.parsed_body, parent
    sign_in users(:non_guest_loud)
    get :comment, params: {topic_id: discussion.topic_id, comment_id: reply.id}
    assert_not response.successful?
    assert_not_includes response.body, parent.body
  end

  test 'reply context cannot serialize a parent left in another topic after moving a branch' do
    other_topic = topics(:alien_discussion_topic)
    @parent.created_topic_item.update_columns(topic_id: other_topic.id, parent_id: other_topic.topicable.created_topic_item.id)
    assert_nil @reply_item.reply_parent
    sign_in users(:member_normal)
    get :comment, params: {topic_id: @discussion.topic_id, comment_id: @reply.id}
    assert_response :success
    assert_nil response.parsed_body.fetch('topic_items').first.fetch('reply_parent_id')
    assert_not_includes response.body, @parent.body
  end

  test 'discarded parent context retains its place without exposing removed text' do
    @parent.discard
    sign_in users(:member_normal)
    get :comment, params: {topic_id: @discussion.topic_id, comment_id: @reply.id}
    assert_response :success
    parent = response.parsed_body.fetch('comments').find { |comment| comment['id'] == @parent.id }
    assert parent
    assert_nil parent.fetch('body')
  end

  private

  def create_comment(parent, body)
    comment = Comment.new(parent: parent, body: body)
    CommentService.create(comment: comment, actor: @actor)
    comment
  end

  def assert_context(json, comment)
    assert_includes json.fetch('parent_topic_items').pluck('id'), comment.created_topic_item.id
    assert_includes json.fetch('comments').pluck('id'), comment.id
  end
end
