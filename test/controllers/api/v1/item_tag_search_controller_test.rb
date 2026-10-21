require 'test_helper'

class Api::V1::ItemTagSearchControllerTest < ActionController::TestCase
  tests Api::V1::SearchController

  setup do
    @topic = topics(:discussion_topic)
    @author = users(:member_normal)
    @comment = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Insurance budget'), actor: @author)
    @item = @comment.created_topic_item
    TopicItemService.update_tags(topic_item: @item, tags: ['Budget'], actor: @author)
    @topic.topicable.update_pg_search_document
    sign_in @author
  end

  test 'tag-only search returns explicitly tagged contributions without inheriting topic tags' do
    get :index, params: {tag: 'Budget'}
    assert_response :success
    results = JSON.parse(response.body).fetch('search_results')
    assert_equal [['Comment', @comment.id]], results.map { |row| [row['searchable_type'], row['searchable_id']] }
    assert_equal ['Budget'], results.first.fetch('tags')
    assert_equal @item.sequence_id, results.first.fetch('sequence_id')
    assert_equal ['Budget'], @topic.reload.tags
  end

  test 'text plus tag matches the content of tagged items rather than untagged siblings' do
    sibling = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Unrelated cheese'), actor: @author)
    get :index, params: {tag: 'Budget', query: 'Insurance'}
    assert_includes JSON.parse(response.body).fetch('search_results').map { |row| row['searchable_id'] }, @comment.id
    get :index, params: {tag: 'Budget', query: 'cheese'}
    assert_empty JSON.parse(response.body).fetch('search_results')
    get :index, params: {query: 'cheese'}
    assert_includes JSON.parse(response.body).fetch('search_results').map { |row| row['searchable_id'] }, sibling.id
  end

  test 'other groups and revoked topic guests cannot discover private assignments by combining filters' do
    %i[alien_quiet former_guest_loud].each do |role|
      sign_in users(role)
      [{tag: 'Budget'}, {tag: 'Budget', author_id: @author.id}, {tag: 'Budget', group_id: @topic.group_id}].each do |params|
        get :index, params: params
        assert_empty JSON.parse(response.body).fetch('search_results'), "#{role}: #{params}"
      end
    end
  end

  test 'direct topic tags are searchable without creating an organization tag' do
    author = users(:guest_normal)
    comment = CommentService.create(comment: Comment.new(parent: topics(:direct_topic).topicable, body: 'Direct insurance'), actor: author)
    TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: ['Private budget'], actor: author)
    sign_in author
    get :index, params: {tag: 'Private budget', org_id: '0'}
    assert_equal [comment.id], JSON.parse(response.body).fetch('search_results').map { |row| row['searchable_id'] }
  end

  test 'hidden comments immediately leave search while retaining their public tags' do
    poll = PollService.create(params: {topic_id: @topic.id, poll_type: 'proposal', title: 'Budget poll',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: users(:admin))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Secret insurance'), actor: @author)
    TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: ['Sensitive'], actor: @author)
    document = PgSearch::Document.find_by!(searchable: comment).attributes.except('id')
    poll.update!(hide_results: 'until_closed')
    assert_not PgSearch::Document.exists?(searchable: comment)
    SearchService.reindex_by_comment_id(comment.id)
    ReindexPollWorker.perform_now(poll.id)
    assert_not PgSearch::Document.exists?(searchable: comment)
    # Simulate an already-running indexing job finishing with an older snapshot.
    PgSearch::Document.create!(document)
    assert_equal ['Sensitive'], comment.created_topic_item.tags
    assert_includes @topic.reload.tags, 'Sensitive'
    get :index, params: {tag: 'Sensitive'}
    assert_empty JSON.parse(response.body).fetch('search_results')
    get :index, params: {query: 'insurance'}
    rows = JSON.parse(response.body).fetch('search_results')
    assert_not rows.any? { |row| row['searchable_type'] == 'Comment' && row['searchable_id'] == comment.id }
    poll.update!(closed_at: Time.current)
    ReindexPollWorker.perform_now(poll.id)
    get :index, params: {tag: 'Sensitive'}
    assert_equal [comment.id], response.parsed_body.fetch('search_results').pluck('searchable_id')
  end

  test 'standalone poll comments include a usable poll route' do
    poll = PollService.create(params: {group_id: @topic.group_id, poll_type: 'proposal', title: 'Standalone budget',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: @author)
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Standalone insurance'), actor: @author)
    TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: ['Standalone'], actor: @author)
    get :index, params: {tag: 'Standalone'}
    row = JSON.parse(response.body).fetch('search_results').sole
    assert_equal poll.key, row.fetch('poll_key')
    assert_equal comment.created_topic_item.sequence_id, row.fetch('sequence_id')
  end
end
