require 'test_helper'

class Api::V1::TopicItemChangeNoteSecurityTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  setup do
    @actor = users(:admin)
    @discussion = topics(:discussion_topic).topicable
    @note = 'Timeline note visible to topic readers'
    DiscussionService.update(discussion: @discussion, actor: @actor,
                             params: { recipient_message: @note, recipient_user_ids: [users(:member_normal).id] })
    @edit = TopicItem.where(itemable: @discussion, kind: 'discussion_edited').last
    @notification = @edit.notifications.find_by!(kind: 'discussion_edited')
    @notification.update!(recipient_context: { private_marker: 'secret routing context' })
  end

  test 'timeline exposes only the occurrence note without recipient fields or extra queries' do
    DiscussionService.update(discussion: @discussion, actor: @actor, params: { recipient_message: 'Later edit note' })
    sign_in users(:guest_normal)
    assert_no_record_cache_fallbacks do
      get :index, params: { topic_id: @discussion.topic_id }
    end
    assert_response :success
    items = response.parsed_body.fetch('topic_items')
    assert_equal @note, items.find { |item| item['id'] == @edit.id }.fetch('change_note')
    assert_equal ['Later edit note', @note].sort,
                 items.select { |item| item['kind'] == 'discussion_edited' }.pluck('change_note').sort
    items.each do |item|
      %w[recipient_message recipient_user_ids recipient_chatbot_ids recipient_audience recipient_context notifications].each do |field|
        assert_not item.key?(field), field
      end
    end
    assert_not_includes response.body, 'secret routing context'
  end

  [:alien, :non_guest_loud, :former_guest_loud, :inactive_guest_loud].each do |role|
    test "private edit note is inaccessible to #{role}" do
      sign_in users(role)
      get :index, params: { topic_id: @discussion.topic_id }
      assert_not response.successful?
      assert_not_includes response.body, @note
    end
  end

  test 'signed out users cannot fetch private edit notes' do
    get :index, params: { topic_id: @discussion.topic_id }
    assert_not response.successful?
    assert_not_includes response.body, @note
  end

  test 'public edit notes are visible without exposing notification recipients' do
    discussion = topics(:public_discussion_topic).topicable
    edit = TopicItems::DiscussionEdited.create!(itemable: discussion, user: @actor)
    NotificationService.create!(kind: 'discussion_edited', subject: edit, actor: @actor,
                                recipient_message: @note, recipient_user_ids: [users(:user).id])
    get :index, params: { topic_id: discussion.topic_id }
    assert_response :success
    assert_equal @note, response.parsed_body.fetch('topic_items').find { |item| item['id'] == edit.id }.fetch('change_note')
    assert_not_includes response.body, 'recipient_user_ids'
  end

  test 'direct topic notes follow its existing guest access boundary' do
    discussion = topics(:direct_topic).topicable
    actor = users(:guest_admin_normal)
    discussion.create_missing_created_topic_item!
    DiscussionService.update(discussion: discussion, actor: actor, params: { recipient_message: @note })
    sign_in users(:guest_normal)
    get :index, params: { topic_id: discussion.topic_id }
    assert_response :success
    assert_includes response.body, @note
    sign_in users(:non_guest_loud)
    get :index, params: { topic_id: discussion.topic_id }
    assert_not response.successful?
    assert_not_includes response.body, @note
  end

  test 'unrelated notifications cannot supply a timeline note with or without the cache' do
    @notification.destroy!
    NotificationService.create!(kind: 'discussion_announced', subject: @edit, actor: @actor,
                                recipient_message: 'Private announcement message')
    NotificationService.create!(kind: 'discussion_edited', subject: @edit, actor: users(:user),
                                recipient_message: 'Unrelated actor message')
    assert_nil @edit.change_note
    sign_in users(:member_normal)
    get :index, params: { topic_id: @discussion.topic_id }
    assert_response :success
    assert_nil response.parsed_body.fetch('topic_items').find { |item| item['id'] == @edit.id }.fetch('change_note')
    assert_not_includes response.body, 'Private announcement message'
    assert_not_includes response.body, 'Unrelated actor message'
  end

  test 'shared realtime serialization includes the edit note without delivery metadata' do
    data = JSON.parse(MessageChannelService.serialize_shared_models([@edit]).to_json)
    assert_equal @note, data.fetch('topic_items').find { |item| item['id'] == @edit.id }.fetch('change_note')
    assert_not_includes data.to_json, 'recipient_user_ids'
    assert_not_includes data.to_json, 'secret routing context'
  end

  test 'non edit occurrences never expose invitation messages' do
    root = @discussion.created_topic_item
    NotificationService.create!(kind: 'new_discussion', subject: root, actor: @actor,
                                recipient_message: 'Private invitation message')
    assert_nil root.change_note
    sign_in users(:member_normal)
    get :index, params: { topic_id: @discussion.topic_id }
    assert_response :success
    assert_not response.parsed_body.fetch('topic_items').find { |item| item['id'] == root.id }.key?('change_note')
    assert_not_includes response.body, 'Private invitation message'
  end
end
