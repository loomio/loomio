require 'test_helper'

class Api::V1::SearchControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @group.add_member!(@user) unless @group.members.include?(@user)

    @discussion = discussions(:discussion)
    @discussion.update!(title: "findme discussion")
    @comment = Comment.new(parent: @discussion, body: "findme in comment")
    CommentService.create(comment: @comment, actor: @user)

    @poll = PollService.create(params: {
      title: "findme poll",
      poll_type: "proposal",
      topic_id: @discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: [ "findme" ]
    }, actor: @user)
    @poll.update!(closed_at: 1.day.ago)

    @outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "findme outcome"
    )
    OutcomeService.create(outcome: @outcome, actor: @user)

    # Rebuild search documents after topic_items are created
    PgSearch::Document.delete_all
    [ Discussion, Comment, Poll, Outcome ].each(&:rebuild_pg_search_documents)
    PgSearch::Document.connection.execute <<~SQL
      INSERT INTO pg_search_words (word, document_count)
      VALUES
        ('democracia', 100),
        ('participativa', 100),
        ('whakawhanaungatanga', 100),
        ('демократия', 100),
        ('findme', 100),
        ('findguestdiscussion', 100),
        ('findprivatesubgroup', 100),
        ('confidential', 100)
      ON CONFLICT (word) DO UPDATE SET document_count = EXCLUDED.document_count
    SQL
  end

  test "returns visible records for group member" do
    sign_in @user

    get :index, params: { query: "findme" }
    results = JSON.parse(response.body)['search_results']

    assert results.any? { |r| r['searchable_type'] == 'Discussion' && r['searchable_id'] == @discussion.id }
    assert results.any? { |r| r['searchable_type'] == 'Comment' }
    assert results.any? { |r| r['searchable_type'] == 'Poll' }
    assert results.any? { |r| r['searchable_type'] == 'Outcome' }
  end

  test "does not return stale documents for a legacy discarded discussion" do
    @discussion.update_columns(discarded_at: Time.current)
    assert PgSearch::Document.where(discussion_id: @discussion.id).exists?

    sign_in @user
    get :index, params: { query: 'findmee' }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |result| result['discussion_key'] == @discussion.key }
  end

  test "does not return records from a discarded topic" do
    @discussion.topic.update_columns(discarded_at: Time.current)
    assert PgSearch::Document.where(topic_id: @discussion.topic.id).exists?

    sign_in @user
    get :index, params: { query: 'findmee' }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |result| result['discussion_key'] == @discussion.key }
  end

  test "respects parent member access to private subgroup discussions" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(
      is_visible_to_parent_members: true,
      parent_members_can_see_discussions: false
    )
    discussion = DiscussionService.create(
      params: {
        group_id: subgroup.id,
        title: "findprivatesubgroup",
        private: true
      },
      actor: users(:admin)
    )
    discussion.update_pg_search_document

    sign_in users(:member)
    get :index, params: { query: "findprivatesubgrop" }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |result| result['searchable_id'] == discussion.id }

    subgroup.update_columns(parent_members_can_see_discussions: true)
    get :index, params: { query: "findprivatesubgrop" }

    results = JSON.parse(response.body)['search_results']
    assert results.any? { |result| result['searchable_id'] == discussion.id }
  end

  test "returns direct discussions only to guests" do
    discussion = DiscussionService.build(
      params: {
        title: "findguestdiscussion",
        private: true,
        description_format: "html"
      },
      actor: users(:admin)
    )
    discussion.save!(validate: false)
    discussion.create_missing_created_topic_item!
    discussion.add_guest!(@user, discussion.author)
    discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: "findguestdiscussion" }

    results = JSON.parse(response.body)['search_results']
    assert results.any? { |result| result['searchable_id'] == discussion.id }

    sign_in users(:alien)
    get :index, params: { query: "findguestdiscussion" }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |result| result['searchable_id'] == discussion.id }

    sign_in @user
    get :index, params: { query: "findguestdiscusison" }

    results = JSON.parse(response.body)['search_results']
    assert results.any? { |result| result['searchable_id'] == discussion.id }

    sign_in users(:alien)
    get :index, params: { query: "findguestdiscusison" }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |result| result['searchable_id'] == discussion.id }
  end

  test "returns group filtered records" do
    sign_in @user

    get :index, params: { query: "findmee", group_id: @group.id }
    results = JSON.parse(response.body)['search_results']

    assert results.any? { |r| r['searchable_type'] == 'Discussion' && r['searchable_id'] == @discussion.id }
  end

  test "filters by group id" do
    sign_in @user
    other_group = groups(:alien_group)
    other_group.add_member!(@user) unless other_group.members.include?(@user)

    get :index, params: { query: "findme", group_id: other_group.id }
    results = JSON.parse(response.body)['search_results']

    assert_not results.any? { |r| r['searchable_id'] == @discussion.id }
  end

  test "handles empty query" do
    sign_in @user

    get :index, params: { query: "" }

    assert_response :success
    results = JSON.parse(response.body)['search_results']
    assert_equal 0, results.length
  end

  test "returns search results in json format" do
    sign_in @user

    get :index, params: { query: "findme" }, format: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json.keys, 'search_results'
  end

  test "returns a result when multiple search terms are misspelled" do
    @discussion.update!(title: 'Democracia participativa')
    @discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: 'democracai partciipativa' }

    result = JSON.parse(response.body)['search_results'].find do |record|
      record['searchable_type'] == 'Discussion' && record['searchable_id'] == @discussion.id
    end
    assert_not_nil result
    assert_includes result['highlight'], '<b>Democracia</b>'
    assert_includes result['highlight'], '<b>participativa</b>'
  end

  test "supports fuzzy matching across writing systems" do
    @discussion.update!(title: 'Whakawhanaungatanga демократия')
    @discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: 'whakawhanaungatnga демократя' }

    results = JSON.parse(response.body)['search_results']
    assert results.any? { |record| record['searchable_type'] == 'Discussion' && record['searchable_id'] == @discussion.id }
  end

  test "ranks exact matches before fuzzy matches" do
    exact_discussion = DiscussionService.create(
      params: { group_id: @group.id, title: 'findmee discussion', private: true },
      actor: users(:admin)
    )
    exact_discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: 'findmee' }

    results = JSON.parse(response.body)['search_results']
    exact_index = results.index { |record| record['searchable_type'] == 'Discussion' && record['searchable_id'] == exact_discussion.id }
    fuzzy_index = results.index { |record| record['searchable_type'] == 'Discussion' && record['searchable_id'] == @discussion.id }
    assert_operator exact_index, :<, fuzzy_index
  end

  test "applies authored ordering across exact and fuzzy matches" do
    exact_discussion = DiscussionService.create(
      params: { group_id: @group.id, title: 'findmee discussion', private: true },
      actor: users(:admin)
    )
    exact_discussion.update_columns(created_at: 1.day.ago)
    exact_discussion.update_pg_search_document

    fuzzy_discussion = DiscussionService.create(
      params: { group_id: @group.id, title: 'findme discussion', private: true },
      actor: users(:admin)
    )
    fuzzy_discussion.update_columns(created_at: 1.day.from_now)
    fuzzy_discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: 'findmee', order: 'authored_at_desc' }

    result = JSON.parse(response.body)['search_results'].first
    assert_equal 'Discussion', result['searchable_type']
    assert_equal fuzzy_discussion.id, result['searchable_id']
  end

  test "applies type filters to fuzzy matches" do
    sign_in @user
    get :index, params: { query: 'findmee', type: 'Discussion' }

    results = JSON.parse(response.body)['search_results']
    assert results.any?
    assert results.all? { |record| record['searchable_type'] == 'Discussion' }
  end

  test "applies tag filters to fuzzy matches" do
    @discussion.topic.update!(tags: [ 'planning' ])
    [ Discussion, Comment, Poll, Outcome ].each(&:rebuild_pg_search_documents)

    sign_in @user
    get :index, params: { query: 'findmee', tag: 'planning' }
    matching_results = JSON.parse(response.body)['search_results']

    get :index, params: { query: 'findmee', tag: 'governance' }
    excluded_results = JSON.parse(response.body)['search_results']

    assert matching_results.any? { |record| record['searchable_id'] == @discussion.id }
    refute excluded_results.any? { |record| record['searchable_id'] == @discussion.id }
  end

  test "does not fuzzy match documents outside the user's groups" do
    alien_discussion = discussions(:alien_discussion)
    alien_discussion.update!(title: 'Confidential strategy')
    alien_discussion.update_pg_search_document

    sign_in @user
    get :index, params: { query: 'confidnetial' }

    results = JSON.parse(response.body)['search_results']
    refute results.any? { |record| record['searchable_id'] == alien_discussion.id }
  end

  test "does not use fuzzy matching for negated queries" do
    sign_in @user
    get :index, params: { query: 'findmee !poll' }

    assert_empty JSON.parse(response.body)['search_results']
  end
end
