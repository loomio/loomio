require 'test_helper'

class Api::V1::StancesControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)

    @group.add_member!(@user)
    @group.add_member!(@another_user)
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
    get :index, params: { poll_id: poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert json['stances'].is_a?(Array)
  end

end
