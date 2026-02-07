require 'test_helper'

class PollsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "polluser#{hex}", email: "polluser#{hex}@example.com", username: "polluser#{hex}", email_verified: true)
    @another_user = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}", email_verified: true)
    @group = Group.new(name: "pollgroup#{hex}", group_privacy: 'closed', is_visible_to_public: true)
    @group.creator = @user
    @group.save!
    @group.add_member!(@user)

    @discussion = Discussion.new(title: "Discussion #{hex}", group: @group, author: @user, private: false)
    DiscussionService.create(discussion: @discussion, actor: @user)

    @poll = Poll.new(
      title: "Poll #{hex}",
      poll_type: 'proposal',
      group: @group,
      author: @user,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    PollService.create(poll: @poll, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  test "displays html export" do
    sign_in @user
    get :export, params: { key: @poll.key }
    assert_response 200
    assert_template 'polls/export'
  end

  test "displays csv export" do
    sign_in @user
    get :export, params: { key: @poll.key }, format: :csv
    assert_response 200
    assert_includes response.body, @poll.title
  end

  test "does not show export to non-coordinators" do
    sign_in @another_user
    get :export, params: { key: @poll.key }
    assert_response 302
  end
end
