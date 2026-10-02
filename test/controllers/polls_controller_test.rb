require 'test_helper'

class PollsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "polluser#{hex}", email: "polluser#{hex}@example.com", username: "polluser#{hex}", email_verified: true)
    @alien = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}", email_verified: true)
    @group = Group.new(name: "pollgroup#{hex}", group_privacy: 'closed', is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    @group.creator = @user
    @group.save!
    @group.add_member!(@user)

    @discussion = DiscussionService.create(params: { title: "Discussion #{hex}", group_id: @group.id, private: false }, actor: @user)

    @poll = PollService.create(params: {
      title: "Poll #{hex}",
      poll_type: 'proposal',
      topic_id: @discussion.topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  test "displays html export" do
    sign_in @user
    get :export, params: { key: @poll.key }
    assert_response 200
    assert_includes response.body, @poll.title
  end

  test "displays csv export" do
    sign_in @user
    get :export, params: { key: @poll.key }, format: :csv
    assert_response 200
    assert_includes response.body, @poll.title
  end

  test 'until-vote HTML and CSV exports include votes before the reader votes' do
    @poll.update!(hide_results: 'until_vote')
    voter = @poll.stances.latest.find_by!(participant_id: @user.id)
    voter.choice = @poll.poll_option_names.first
    voter.reason = 'Export before voting marker'
    StanceService.create(stance: voter, actor: @user)
    @group.add_member!(@alien)
    sign_in @alien

    [:html, :csv].each do |format|
      get :export, params: {key: @poll.key}, format: format
      assert_response :success
      assert_includes response.body, 'Export before voting marker'
    end

    @poll.update!(hide_results: 'until_closed')
    get :export, params: {key: @poll.key}, format: :csv
    assert_response :redirect
    refute_includes response.body, 'Export before voting marker'
  end

  test "unsubscribe token does not authorize a private poll export" do
    @discussion.topic.update!(private: true)
    @user.update_columns(unsubscribe_token: 'poll-export-unsubscribe-token')

    get :export, params: {
      key: @poll.key,
      unsubscribe_token: @user.unsubscribe_token
    }, format: :csv

    assert_response :redirect
  end

  test "does not show export to users who cannot see the poll" do
    @discussion.topic.update!(private: true)
    sign_in @alien
    get :export, params: { key: @poll.key }
    assert_response 302
  end
end
