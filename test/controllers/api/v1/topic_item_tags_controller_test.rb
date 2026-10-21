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
    assert_empty json.fetch('topics').first.fetch('root_tags')
    assert json.fetch('topics').first.fetch('has_tagged_replies')
    tag = @topic.group.tags.find_by!(name: 'Finance')
    assert_includes Tag::COLORS, tag.color
    assert_equal tag.color, json.fetch('tags').find { |row| row['id'] == tag.id }.fetch('color')
  end

  test 'other members cannot change someone elses assignments' do
    sign_in users(:member_quiet)
    patch :tags, params: {id: @item.id, tags: ['Finance']}
    assert_response :forbidden
    assert_equal ['Budget'], @item.reload.tags
  end

  test 'an author can tag their poll comment before voting in an until-vote poll' do
    poll = PollService.create(params: {topic_id: @topic.id, poll_type: 'proposal', title: 'Poll',
      hide_results: 'until_vote', poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: users(:admin))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Before voting'), actor: @author)
    assert_not poll.stances.decided.exists?(participant_id: @author.id)
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
    root = topic.topicable.created_topic_item
    root.update!(tags: ['Public'])
    get :tagged, params: {topic_id: topic.id, tag: 'Public'}
    assert_response :success
    patch :tags, params: {id: root.id, tags: ['Changed']}
    assert_includes [401, 403], response.status
  end
end
