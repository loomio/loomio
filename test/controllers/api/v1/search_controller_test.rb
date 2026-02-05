require 'test_helper'

class Api::V1::SearchControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_member!(@user) unless @group.members.include?(@user)

    @discussion = create_discussion(group: @group, author: @user, title: "findme discussion")
    @comment = Comment.new(discussion: @discussion, body: "findme in comment")
    CommentService.create(comment: @comment, actor: @user)

    @poll = Poll.new(
      title: "findme poll",
      poll_type: "proposal",
      discussion: @discussion,
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["findme"]
    )
    PollService.create(poll: @poll, actor: @user)

    @outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "findme outcome"
    )
    OutcomeService.create(outcome: @outcome, actor: @user)
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
    other_group = groups(:another_group)
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
