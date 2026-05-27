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
      poll_option_names: ["findme"]
    }, actor: @user)
    @poll.update!(closed_at: 1.day.ago)

    @outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "findme outcome"
    )
    OutcomeService.create(outcome: @outcome, actor: @user)

    # Rebuild search documents after events are created
    PgSearch::Document.delete_all
    [Discussion, Comment, Poll, Outcome].each(&:rebuild_pg_search_documents)
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

  test "returns group filtered records" do
    sign_in @user

    get :index, params: { query: "findme", group_id: @group.id }
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
end
