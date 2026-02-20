require 'test_helper'

class Api::V1::PollsControllerTest < ActionController::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
  end

  # Show tests
  test "show displays a poll" do
    poll = Poll.new(
      title: "POLL!",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    get :show, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['polls'].length
    assert_equal poll.key, json['polls'][0]['key']
  end

  # Index tests
  test "index responds successfully" do
    poll = Poll.new(
      title: "POLL!",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    get :index
    assert_response :success
  end

  # Create tests
  test "create creates a poll in discussion" do
    sign_in @user

    assert_difference 'Poll.count', 1 do
      post :create, params: {
        poll: {
          title: "hello",
          poll_type: "proposal",
          details: "is it me you're looking for?",
          discussion_id: @discussion.id,
          options: ["agree", "abstain", "disagree", "block"],
          closing_at: 3.days.from_now.at_beginning_of_hour
        }
      }
    end

    assert_response :success
    poll = Poll.last
    assert_equal "hello", poll.title
    assert_equal @discussion, poll.discussion
    assert_equal @user, poll.author
    assert_includes poll.admins, @user
  end

  # Discard tests
  test "discard allows poll author to discard" do
    poll = Poll.new(
      title: "discardable",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    delete :discard, params: { id: poll.id }
    assert_response :success

    poll.reload
    assert poll.discarded?
    assert_equal @user.id, poll.discarded_by
  end

  # Receipts tests
  test "receipts returns receipts for a poll" do

    poll = Poll.new(
      title: "receipts test",
      poll_type: "proposal",
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    get :receipts, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal poll.title, json['poll_title']
    assert json.key?('receipts')
  end

  test "receipts allowed for non-admin member by default" do


    poll = Poll.new(
      title: "receipts test",
      poll_type: "proposal",
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @another_user
    get :receipts, params: { id: poll.key }
    assert_response :success
  end

  test "receipts denied for non-admin member when admin only env set" do
    ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY'] = '1'


    poll = Poll.new(
      title: "receipts test",
      poll_type: "proposal",
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @another_user
    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  ensure
    ENV.delete('LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY')
  end

  test "receipts allowed for group admin when admin only env set" do
    ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY'] = '1'

    poll = Poll.new(
      title: "receipts test",
      poll_type: "proposal",
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    get :receipts, params: { id: poll.key }
    assert_response :success
  ensure
    ENV.delete('LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY')
  end

  # Close tests
  test "close closes an open poll" do
    poll = Poll.new(
      title: "closeable",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    post :close, params: { id: poll.id }
    assert_response :success

    poll.reload
    assert poll.closed?
  end
end
