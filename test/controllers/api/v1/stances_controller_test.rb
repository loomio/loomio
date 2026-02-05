require 'test_helper'

class Api::V1::StancesControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)

    @group.add_member!(@user)
    @group.add_member!(@another_user)
  end

  test "create creates a stance" do
    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @another_user
    post :create, params: {
      stance: {
        poll_id: poll.id,
        poll_option_ids: [poll.poll_options.first.id]
      }
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal @another_user.id, json['stances'][0]['participant_id']
  end

  test "create denies access to guests" do
    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    post :create, params: {
      stance: {
        poll_id: poll.id,
        poll_option_ids: [poll.poll_options.first.id]
      }
    }

    assert_response :forbidden
  end

  test "uncast removes a stance" do
    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    # Create initial stance
    post :create, params: {
      stance: {
        poll_id: poll.id,
        poll_option_ids: [poll.poll_options.first.id]
      }
    }

    assert_response :success

    # Now uncast it
    delete :uncast, params: { id: Stance.last.id }
    assert_response :success

    @user.reload
    assert_equal 0, @user.stances.where(poll_id: poll.id).count
  end

  test "show returns a stance" do
    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    post :create, params: {
      stance: {
        poll_id: poll.id,
        poll_option_ids: [poll.poll_options.first.id]
      }
    }

    stance = Stance.last
    get :show, params: { id: stance.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal stance.id, json['stances'][0]['id']
  end

  test "index returns stances for a poll" do
    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: @user,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    sign_in @user
    post :create, params: {
      stance: {
        poll_id: poll.id,
        poll_option_ids: [poll.poll_options.first.id]
      }
    }

    get :index, params: { poll_id: poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert json['stances'].present?
  end
end
