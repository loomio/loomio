require 'test_helper'

class Api::V1::StancesControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)

    @group.add_admin!(@user)
    @group.add_member!(@another_user)

    @discussion = create_discussion(group: @group, author: @user)
    @poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: @poll, actor: @user)
    @poll.reload
  end

  # -- Index tests --

  test "index returns stances for a poll" do
    sign_in @user
    get :index, params: { poll_id: @poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert json['stances'].is_a?(Array)
  end

  test "index does not allow unauthorized users" do
    outsider = User.create!(name: 'Outsider', email: "outsider#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider#{SecureRandom.hex(4)}")
    sign_in outsider
    get :index, params: { poll_id: @poll.id }
    assert_response :forbidden
  end

  test "index hides participant_id for anonymous polls" do
    @poll.update!(anonymous: true)
    # Another user's stance exists from auto-creation
    sign_in @user
    get :index, params: { poll_id: @poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    participant_ids = json['stances'].map { |s| s['participant_id'] }
    # In anonymous polls, participant_ids should be nil
    participant_ids.each do |pid|
      assert_nil pid, "participant_id should be nil in anonymous poll"
    end
  end

  # -- Stance admin actions --

  test "revoke with permission sets revoked_at" do
    voter = User.create!(name: 'Voter', email: "voter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)

    assert_nil stance.reload.revoked_at

    sign_in @user  # admin
    post :revoke, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :success
    assert_not_nil stance.reload.revoked_at
  end

  test "revoke without permission returns 403" do
    voter = User.create!(name: 'Voter2', email: "voter2#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter2#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)

    outsider = User.create!(name: 'Outsider', email: "outsider2#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider2#{SecureRandom.hex(4)}")

    sign_in outsider
    post :revoke, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :forbidden
    assert_nil stance.reload.revoked_at
  end

  test "make_admin with permission makes user admin of poll" do
    voter = User.create!(name: 'Voter3', email: "voter3#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter3#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)

    assert_equal false, stance.reload.admin

    sign_in @user  # group admin
    post :make_admin, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :success
    assert_equal true, stance.reload.admin
  end

  test "make_admin without permission returns 403" do
    voter = User.create!(name: 'Voter4', email: "voter4#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter4#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)

    outsider = User.create!(name: 'Outsider3', email: "outsider3#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider3#{SecureRandom.hex(4)}")

    sign_in outsider
    post :make_admin, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :forbidden
    assert_equal false, stance.reload.admin
  end

  test "remove_admin with permission removes admin status" do
    voter = User.create!(name: 'Voter5', email: "voter5#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter5#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)
    stance.update!(admin: true)

    assert_equal true, stance.reload.admin

    sign_in @user  # group admin
    post :remove_admin, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :success
    assert_equal false, stance.reload.admin
  end

  test "remove_admin without permission returns 403" do
    voter = User.create!(name: 'Voter6', email: "voter6#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter6#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)
    stance.update!(admin: true)

    outsider = User.create!(name: 'Outsider4', email: "outsider4#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider4#{SecureRandom.hex(4)}")

    sign_in outsider
    post :make_admin, params: { participant_id: stance.participant_id, poll_id: stance.poll_id }
    assert_response :forbidden
    assert_equal true, stance.reload.admin
  end

  # -- Uncast tests --

  test "uncast sets cast_at to nil for own vote" do
    voter = User.create!(name: 'UncastVoter', email: "uncastvoter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "uncastvoter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    stances = PollService.invite(poll: @poll, actor: @user, params: { recipient_emails: [voter.email] })
    stance = @poll.stances.latest.find_by(participant_id: voter.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my vote"
    }
    StanceService.update(stance: stance, actor: voter, params: stance_params)
    assert_not_nil stance.reload.cast_at

    sign_in voter
    put :uncast, params: { id: stance.id }
    assert_response :success
    assert_nil @poll.stances.latest.find_by(participant_id: voter.id).cast_at
  end

  test "uncast does not allow uncasting another user's vote" do
    voter = User.create!(name: 'UncastVoter2', email: "uncastvoter2#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "uncastvoter2#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    PollService.invite(poll: @poll, actor: @user, params: { recipient_emails: [voter.email] })
    stance = @poll.stances.latest.find_by(participant_id: voter.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my vote"
    }
    StanceService.update(stance: stance, actor: voter, params: stance_params)

    sign_in @user  # not the voter
    put :uncast, params: { id: stance.id }
    assert_includes [403, 404], response.status
    assert_not_nil stance.reload.cast_at
  end

  test "uncast returns 403 when poll is closed" do
    voter = User.create!(name: 'UncastVoter3', email: "uncastvoter3#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "uncastvoter3#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    PollService.invite(poll: @poll, actor: @user, params: { recipient_emails: [voter.email] })
    stance = @poll.stances.latest.find_by(participant_id: voter.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my vote"
    }
    StanceService.update(stance: stance, actor: voter, params: stance_params)
    @poll.update!(closed_at: Time.now)

    sign_in voter
    put :uncast, params: { id: stance.id }
    assert_response :forbidden
  end

  # -- Create tests --

  test "create returns 403 for logged out users" do
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my stance"
    }
    post :create, params: { stance: stance_params }
    assert_response :forbidden
  end

  test "create denies access for non-members" do
    outsider = User.create!(name: 'NonMember', email: "nonmember#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "nonmember#{SecureRandom.hex(4)}")
    sign_in outsider
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my stance"
    }
    post :create, params: { stance: stance_params }
    assert_response :forbidden
  end

  test "create allows group member to vote" do
    sign_in @another_user
    stance = @poll.stances.find_by(participant_id: @another_user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "here is my stance"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success
  end

  test "specified_voters_only true prevents group member from voting via create" do
    @poll.update!(specified_voters_only: true)
    new_member = User.create!(name: 'NewMember', email: "newmember#{SecureRandom.hex(4)}@example.com",
                              email_verified: true, username: "newmember#{SecureRandom.hex(4)}")
    @group.add_member!(new_member)
    sign_in new_member
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my stance"
    }
    post :create, params: { stance: stance_params }
    assert_response :forbidden
  end

  test "specified_voters_only true allows poll guest to vote" do
    @poll.update!(specified_voters_only: true)
    guest = User.create!(name: 'PollGuest', email: "pollguest#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "pollguest#{SecureRandom.hex(4)}")
    stance = @poll.add_guest!(guest, @user)
    sign_in guest
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my stance"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success
  end

  test "validates minimum stance choices for proposals" do
    sign_in @another_user
    stance = @poll.stances.find_by(participant_id: @another_user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [],
      reason: "empty vote"
    }
    assert_no_difference 'Stance.count' do
      post :update, params: { id: stance.id, stance: stance_params }
    end
    assert_response :unprocessable_entity
  end
end
