require 'test_helper'

class Api::V1::OutcomesControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @non_member_user = User.create!(name: "Non Member", username: "nonmember", email: "nonmember@example.com")
    @group = groups(:group)
    @discussion = discussions(:discussion)

    # Create poll
    @poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      topic_id: @discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: @user)
    @poll.update!(closed_at: 1.day.ago)

    # Create meeting poll
    @meeting_poll = PollService.create(params: {
      title: "Meeting Poll",
      poll_type: "meeting",
      topic_id: @discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: ["2026-01-15"]
    }, actor: @user)
    @meeting_poll.update!(closed_at: 1.day.ago)

    # Create another poll
    @another_poll = PollService.create(params: {
      title: "Another Poll",
      poll_type: "proposal",
      topic_id: @discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: @user)
    @another_poll.update!(closed_at: 1.day.ago)

    # Create outcome
    @outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "Original outcome statement"
    )
    OutcomeService.create(outcome: @outcome, actor: @user)

    @outcome_params = { poll_id: @poll.id, statement: "We should do this" }
    @meeting_params = @outcome_params.merge(
      poll_id: @meeting_poll.id,
      poll_option_id: @meeting_poll.poll_option_ids.first,
      event_description: "Eat those krabs",
      event_location: "The Krusty Krab"
    )

    @group.add_member! @user unless @group.members.include?(@user)
  end

  # Create action tests
  test "create creates a new outcome" do
    sign_in @user

    assert_difference 'Outcome.count', 1 do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :success

    outcome = Outcome.last
    assert_equal @outcome_params[:statement], outcome.statement
    assert_equal @poll, outcome.poll
  end

  test "create notifies group" do
    sign_in @user
    third_user = User.create!(name: "Third Member", username: "thirdmember", email: "third@example.com")
    @group.add_member! third_user

    params = {
      poll_id: @poll.id,
      statement: "we did it",
      recipient_audience: 'group'
    }

    assert_difference 'Outcome.count', 1 do
      post :create, params: { outcome: params }
    end

    assert_response :success

    outcome = Outcome.find(JSON.parse(response.body)['outcomes'][0]['id'])
    assert_equal 3, outcome.created_event.notifications.count
  end

  test "create does not allow creating an invalid outcome" do
    sign_in @user
    @outcome_params[:statement] = ""

    assert_no_difference 'Outcome.count' do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :unprocessable_entity
  end

  test "create can associate a poll option with the outcome" do
    sign_in @user
    @outcome_params[:poll_option_id] = @poll.poll_options.first.id

    assert_difference '@poll.outcomes.count', 1 do
      post :create, params: { outcome: @outcome_params }
    end

    assert_equal @poll.poll_options.first, Outcome.last.poll_option
  end

  test "create validates the poll option id" do
    sign_in @user

    # Create a different poll to get an invalid poll option
    invalid_poll = PollService.create(params: {
      title: "Invalid Poll",
      poll_type: "proposal",
      topic_id: @discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: ["Maybe"]
    }, actor: @user)

    @outcome_params[:poll_option_id] = invalid_poll.poll_options.first.id

    assert_no_difference '@poll.outcomes.count' do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :unprocessable_entity
  end

  test "create does not allow visitors to create outcomes" do
    assert_no_difference 'Outcome.count' do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :forbidden
  end

  test "create does not allow non members to create outcomes" do
    sign_in @non_member_user

    assert_no_difference 'Outcome.count' do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :forbidden
  end

  test "create does not allow outcomes on open polls" do
    sign_in @user
    @poll.update(closed_at: nil)

    assert_no_difference 'Outcome.count' do
      post :create, params: { outcome: @outcome_params }
    end

    assert_response :forbidden
  end

  test "create can store a calendar invite for date polls" do
    sign_in @user

    assert_difference 'Outcome.count', 1 do
      post :create, params: { outcome: @meeting_params }
    end

    outcome = Outcome.last
    assert_equal @meeting_params[:event_description], outcome.event_description
    assert_equal @meeting_params[:event_location], outcome.event_location
    assert outcome.calendar_invite.present?
    assert_match /#{@meeting_params[:event_description]}/, outcome.calendar_invite
    assert_match /#{@meeting_params[:event_location]}/, outcome.calendar_invite
  end

  # Update action tests
  test "update updates an outcome" do
    sign_in @user
    @outcome_params[:statement] = "updated"

    assert_no_difference 'Outcome.count' do
      post :update, params: { id: @outcome.id, outcome: @outcome_params }
    end

    assert_response :success

    @outcome.reload
    assert_equal "updated", @outcome.statement
    assert_equal true, @outcome.latest
  end

  test "update does not allow updating to an invalid outcome" do
    sign_in @user
    @outcome_params[:statement] = ""

    post :update, params: { id: @outcome.id, outcome: @outcome_params }

    assert_response :unprocessable_entity
  end

  test "update does not allow visitors to update outcomes" do
    post :update, params: { id: @outcome.id, outcome: @outcome_params }

    assert_response :forbidden
  end

  test "update does not allow non members to update outcomes" do
    sign_in @non_member_user

    post :update, params: { id: @outcome.id, outcome: @outcome_params }

    assert_response :forbidden
  end

  test "update does not allow outcomes to be updated on open polls" do
    sign_in @user
    @poll.update(closed_at: nil)

    post :update, params: { id: @outcome.id, outcome: @outcome_params }

    assert_response :forbidden
  end
end
