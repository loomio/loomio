require 'test_helper'

class Api::V1::TopicItemTagsControllerTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  setup do
    @topic = topics(:discussion_topic)
    @author = users(:member_normal)
    @comment = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Budget'), actor: @author)
    @item = @comment.created_topic_item
    TopicItemService.update_tags(topic_item: @item, tags: ['Budget'], actor: @author)
  end

  test 'authors can update item tags and receive the aggregate and explicit assignments' do
    sign_in @author
    patch :tags, params: {id: @item.id, tags: ['Finance']}
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal ['Finance'], json.fetch('topic_items').find { |row| row['id'] == @item.id }.fetch('tags')
    assert_equal ['Finance'], json.fetch('topics').find { |row| row['id'] == @topic.id }.fetch('tags')
    root = @topic.topicable.created_topic_item
    assert_empty json.fetch('parent_topic_items').find { |row| row['id'] == root.id }.fetch('tags')
    assert json.fetch('topics').first.fetch('has_tagged_replies')
    tag = @topic.group.tags.find_by!(name: 'Finance')
    assert_includes Tag::COLORS, tag.color
    assert_equal tag.color, json.fetch('tags').find { |row| row['id'] == tag.id }.fetch('color')
  end

  test 'other members cannot change someone elses assignments' do
    @topic.group.update!(members_can_edit_discussions: false)
    sign_in users(:member_quiet)
    patch :tags, params: {id: @item.id, tags: ['Finance']}
    assert_response :forbidden
    assert_equal ['Budget'], @item.reload.tags
  end

  test 'context editors can apply existing tags to others contributions without creating tag names' do
    @topic.group.update!(members_can_edit_discussions: true, members_can_create_tags: false)
    Tag.create!(group: @topic.group, name: 'Finance')
    sign_in users(:member_quiet)

    patch :tags, params: {id: @item.id, tags: ['Finance', 'New tag']}

    assert_response :success
    assert_equal ['Finance'], @item.reload.tags
    assert_equal ['Finance'], @topic.reload.tags
    assert_not Tag.exists?(group: @topic.group, name: 'New tag')
  end

  test 'loading a reply includes the opening tags for discussion and poll topics' do
    poll = PollService.create(params: {group_id: @topic.group_id, poll_type: 'proposal', title: 'Standalone poll',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: users(:admin))
    sign_in @author

    [@topic, poll.topic].each do |topic|
      root = topic.topicable.created_topic_item
      TopicItemService.update_tags(topic_item: root, tags: ['Opening'], actor: users(:admin))
      comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Later reply'), actor: @author)

      assert_no_record_cache_fallbacks do
        get :index, params: {topic_id: topic.id, sequence_id_gte: comment.created_topic_item.sequence_id, per: 1}
      end

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal [comment.created_topic_item.id], json.fetch('topic_items').map { |row| row['id'] }
      assert_equal ['Opening'], json.fetch('parent_topic_items').find { |row| row['id'] == root.id }.fetch('tags')
    end
  end

  test 'an author can tag their poll comment before voting in an until-vote poll' do
    poll = PollService.create(params: {topic_id: @topic.id, poll_type: 'proposal', title: 'Poll',
      hide_results: 'until_vote', poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: users(:admin))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Before voting'), actor: @author)
    assert_not poll.stances.cast.exists?(participant_id: @author.id)
    sign_in @author

    patch :tags, params: {id: comment.created_topic_item.id, tags: ['Question']}

    assert_response :success
    assert_equal ['Question'], comment.created_topic_item.tags
    assert_includes response.parsed_body.fetch('topic_items').flat_map { |row| row.fetch('tags') }, 'Question'
  end

  test 'tag browsing returns only matches with parent context and uses bounded limit offset pagination' do
    second = CommentService.create(comment: Comment.new(parent: @comment, body: 'More budget'), actor: @author).created_topic_item
    TopicItemService.update_tags(topic_item: second, tags: ['Budget'], actor: @author)
    sign_in @author
    assert_no_record_cache_fallbacks do
      get :tagged, params: {topic_id: @topic.id, tag: 'Budget', limit: 1, offset: 1, per: 500}
    end
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal [second.id], json.fetch('topic_items').map { |row| row['id'] }
    assert_includes json.fetch('parent_topic_items').map { |row| row['id'] }, @item.id
  end

  test 'tag browsing respects the existing access matrix' do
    %i[alien_quiet former_guest_loud inactive_guest_loud].each do |role|
      sign_in users(role)
      get :tagged, params: {topic_id: @topic.id, tag: 'Budget'}
      assert_includes [401, 403], response.status, role.to_s
      refute_includes response.body, @comment.body
    end
  end

  test 'signed out readers can browse public tags but cannot edit them' do
    topic = topics(:public_discussion_topic)
    topic.group.update!(members_can_edit_discussions: true)
    root = topic.topicable.created_topic_item
    root.update!(tags: ['Public'])
    get :tagged, params: {topic_id: topic.id, tag: 'Public'}
    assert_response :success
    patch :tags, params: {id: root.id, tags: ['Changed']}
    assert_includes [401, 403], response.status
  end
end
