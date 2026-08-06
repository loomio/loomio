require 'test_helper'

class Api::V1::StancesControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @group = groups(:group)

    @discussion = discussions(:discussion)
    @poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      topic_id: @discussion.topic.id,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now
    }, actor: @admin)
  end

  # -- Index tests --

  test "index returns stances for a poll" do
    sign_in @admin
    get :index, params: { poll_id: @poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert json['stances'].is_a?(Array)
    stance = json['stances'].first
    assert stance.key?('cast_at')
    assert stance.key?('created_at')
    assert stance.key?('updated_at')
    assert stance.key?('order_at')
  end

  test "until vote has the same backend response as results off" do
    @poll.update!(hide_results: 'until_vote')
    admin_stance = @poll.stances.find_by!(participant_id: @admin.id)
    admin_stance.update!(
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      cast_at: Time.current
    )

    sign_in @user
    get :index, params: { poll_id: @poll.id }

    assert_response :success
    until_vote_payload = JSON.parse(response.body)
    until_vote_poll = until_vote_payload['polls'].find { |poll| poll['id'] == @poll.id }

    @poll.update!(hide_results: 'off')
    get :index, params: { poll_id: @poll.id }

    assert_response :success
    results_off_payload = JSON.parse(response.body)
    results_off_poll = results_off_payload['polls'].find { |poll| poll['id'] == @poll.id }
    assert_equal results_off_payload['stances'], until_vote_payload['stances']
    assert_equal results_off_poll.except('hide_results'), until_vote_poll.except('hide_results')
  end

  test "users action returns participants for anonymous polls" do
    @poll.update!(anonymous: true)
    sign_in @admin
    get :users, params: {poll_id: @poll.id}
    assert_response :success

    user_ids = JSON.parse(response.body).fetch('users').map { |user| user['id'] }
    assert_includes user_ids, @admin.id
  end

  test "users action returns the named electorate for detached anonymous polls with an empty query" do
    poll = create_detached_anonymous_poll
    sign_in @admin

    get :users, params: { poll_id: poll.id, query: "" }

    assert_response :success
    user_ids = JSON.parse(response.body).fetch("users").pluck("id")
    assert_equal poll.anonymous_poll_voters.pluck(:voter_id).sort, user_ids.sort
  end

  test "users action denies a detached anonymous poll participant" do
    poll = create_detached_anonymous_poll
    assert poll.anonymous_poll_voters.exists?(voter_id: @user.id)
    sign_in @user

    get :users, params: { poll_id: poll.id, query: "" }

    assert_response :forbidden
  end

  test "users action denies a signed-out detached anonymous poll viewer" do
    poll = create_detached_anonymous_poll

    get :users, params: { poll_id: poll.id, query: "" }

    assert_response :forbidden
  end

  test "users action denies an ordinary poll participant" do
    sign_in @user

    get :users, params: { poll_id: @poll.id }

    assert_response :forbidden
  end

  test "users action denies a public poll viewer" do
    public_poll = Poll.create!(
      title: 'Public roster poll',
      poll_type: 'proposal',
      topic: discussions(:public_discussion).topic,
      author: @admin,
      poll_option_names: ['Agree', 'Disagree'],
      closing_at: 5.days.from_now
    )
    public_viewer = users(:alien)
    assert public_viewer.ability.can?(:show, public_poll)
    sign_in public_viewer

    get :users, params: { poll_id: public_poll.id }

    assert_response :forbidden
  end

  test "index does not allow unauthorized users" do
    outsider = User.create!(name: 'Outsider', email: "outsider#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider#{SecureRandom.hex(4)}")
    sign_in outsider
    get :index, params: { poll_id: @poll.id }
    assert_response :forbidden
  end

  test "index does not use a foreign stance to include participant emails" do
    @group.membership_for(@user).update!(admin: true)
    source_poll = PollService.create(params: {
      title: "Email scope source",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 1.day.from_now
    }, actor: @user)
    source_stance = source_poll.stances.find_by!(participant_id: @user.id)

    hex = SecureRandom.hex(4)
    owner = User.create!(
      name: "Email scope owner",
      email: "email-scope-owner-#{hex}@example.com",
      email_verified: true,
      username: "emailscopeowner#{hex}"
    )
    victim = User.create!(
      name: "Email scope victim",
      email: "email-scope-victim-#{hex}@example.com",
      email_verified: true,
      username: "emailscopevictim#{hex}"
    )
    target_group = Group.create!(
      name: "Email scope target",
      handle: "email-scope-target-#{hex}",
      group_privacy: "secret",
      creator: owner
    )
    Membership.create!(group: target_group, user: owner, admin: true, accepted_at: Time.current)
    Membership.create!(group: target_group, user: @user, admin: false, accepted_at: Time.current)
    Membership.create!(group: target_group, user: victim, admin: false, accepted_at: Time.current)
    target_poll = PollService.create(params: {
      title: "Email scope target poll",
      poll_type: "proposal",
      group_id: target_group.id,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 1.day.from_now
    }, actor: owner)

    sign_in @user
    get :index, params: {poll_id: target_poll.id, id: source_stance.id}

    assert_response :success
    serialized_victim = JSON.parse(response.body).fetch('users').find { |user| user['id'] == victim.id }
    assert_not_nil serialized_victim
    assert_not serialized_victim.key?('email')
  end

  test "index hides identifying metadata for anonymous polls" do
    @poll.update!(anonymous: true)
    # Another user's stance exists from auto-creation
    sign_in @admin
    get :index, params: { poll_id: @poll.id }
    assert_response :success

    json = JSON.parse(response.body)
    participant_ids = json['stances'].map { |s| s['participant_id'] }
    # In anonymous polls, participant_ids should be nil
    participant_ids.each do |pid|
      assert_nil pid, "participant_id should be nil in anonymous poll"
    end

    json['stances'].each do |stance|
      assert_not stance.key?('cast_at')
      assert_not stance.key?('created_at')
      assert_not stance.key?('updated_at')
      assert_not stance.key?('order_at')
    end
  end

  test "index does not reveal anonymous choices or voting order before results are visible" do
    @poll.update!(anonymous: true, hide_results: 'until_closed')
    @poll.stances.first.update_columns(cast_at: 1.minute.ago)
    @poll.stances.last.update_columns(cast_at: 2.minutes.ago)
    own_id = @poll.stances.find_by(participant_id: @admin.id).id

    sign_in @admin
    get :index, params: { poll_id: @poll.id }
    assert_response :success

    stances = JSON.parse(response.body)['stances']

    assert_equal @poll.stances.latest.order(:id).pluck(:id), stances.map { |stance| stance['id'] }

    # Other voters' choices stay hidden until results are visible.
    stances.reject { |stance| stance['id'] == own_id }.each do |stance|
      assert_not stance.key?('none_of_the_above')
      assert_not stance.key?('option_scores')
    end
  end

  # -- Revoke actions --

  test "revoke with permission sets revoked_at" do
    voter = User.create!(name: 'Voter', email: "voter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "voter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)
    stance = @poll.stances.find_by(participant_id: voter.id) ||
             @poll.stances.create!(participant_id: voter.id, latest: true)

    assert_nil stance.reload.revoked_at

    sign_in @admin  # admin
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

  test "redact with permission sets redacted_at and hides reason in response" do
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "moderate this"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success

    sign_in @admin
    patch :redact, params: { id: stance.id }
    assert_response :success

    json = JSON.parse(response.body)
    redacted_stance = json['stances'].find { |record| record['id'] == stance.id }
    assert_not_nil stance.reload.redacted_at
    assert_not_nil redacted_stance['redacted_at']
    assert_not redacted_stance.key?('reason')
    assert_not redacted_stance.key?('attachments')
    assert_not redacted_stance.key?('link_previews')
    assert redacted_stance.key?('option_scores')
  end

  test "unredact restores reason visibility" do
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "restore this"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success

    sign_in @admin
    patch :redact, params: { id: stance.id }
    assert_response :success
    assert_not_nil stance.reload.redacted_at

    patch :unredact, params: { id: stance.id }
    assert_response :success
    assert_nil stance.reload.redacted_at

    json = JSON.parse(response.body)
    restored_stance = json['stances'].find { |s| s['id'] == stance.id }
    assert restored_stance.key?('reason')
  end

  test "unredact without permission returns 403" do
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
    stance.update!(redacted_at: Time.zone.now)

    patch :unredact, params: { id: stance.id }
    assert_response :forbidden
    assert_not_nil stance.reload.redacted_at
  end

  test "redact without permission returns 403" do
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "moderate this"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success

    patch :redact, params: { id: stance.id }
    assert_response :forbidden
    assert_nil stance.reload.redacted_at
  end

  # -- Uncast tests --

  test "uncast sets cast_at to nil for own vote" do
    voter = User.create!(name: 'UncastVoter', email: "uncastvoter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "uncastvoter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    stances = PollService.invite(poll: @poll, actor: @admin, params: { recipient_emails: [voter.email] })
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

    PollService.invite(poll: @poll, actor: @admin, params: { recipient_emails: [voter.email] })
    stance = @poll.stances.latest.find_by(participant_id: voter.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "my vote"
    }
    StanceService.update(stance: stance, actor: voter, params: stance_params)

    sign_in @admin  # not the voter
    put :uncast, params: { id: stance.id }
    assert_includes [403, 404], response.status
    assert_not_nil stance.reload.cast_at
  end

  test "uncast returns 403 when poll is closed" do
    voter = User.create!(name: 'UncastVoter3', email: "uncastvoter3#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "uncastvoter3#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    PollService.invite(poll: @poll, actor: @admin, params: { recipient_emails: [voter.email] })
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
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
    stance_params = {
      poll_id: @poll.id,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id }],
      reason: "here is my stance"
    }
    post :update, params: { id: stance.id, stance: stance_params }
    assert_response :success
  end

  test "update requires a reason when disagreeing" do
    @poll.update!(stance_reason_required: "required_when_disagreeing")
    stance = @poll.stances.find_by!(participant_id: @user.id)
    disagreement = @poll.poll_options.last
    disagreement.update!(icon: "disagree")
    sign_in @user

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [{poll_option_id: disagreement.id}],
        reason: ""
      }
    }

    assert_response :unprocessable_entity
    assert_nil stance.reload.cast_at
  end

  test "update accepts disagreement with a reason" do
    @poll.update!(stance_reason_required: "required_when_disagreeing")
    stance = @poll.stances.find_by!(participant_id: @user.id)
    disagreement = @poll.poll_options.last
    disagreement.update!(icon: "disagree")
    sign_in @user

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [{poll_option_id: disagreement.id}],
        reason: "I have an objection"
      }
    }

    assert_response :success
    assert_equal "I have an objection", @poll.stances.latest.find_by!(participant_id: @user.id).reason
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
    stance = @poll.stances.create!(participant_id: guest.id, inviter: @admin)
    @poll.add_guest!(guest, @admin)
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
    sign_in @user
    stance = @poll.stances.find_by(participant_id: @user.id)
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

  test "index returns anonymous stances with their database ids in id order" do
    anon = anon_poll_with_voters(4)
    poll = anon[:poll]
    sign_in anon[:voters].first

    get :index, params: {poll_id: poll.id}
    assert_response :success

    exposed = JSON.parse(response.body)['stances'].map { |stance| stance['id'] }
    assert_equal poll.stances.latest.order(:id).pluck(:id), exposed
  end

  private

  def create_detached_anonymous_poll
    PollService.create(
      params: {
        title: "Detached anonymous poll",
        poll_type: "proposal",
        group_id: @group.id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"],
        closing_at: 5.days.from_now
      },
      actor: @admin
    )
  end

  def anon_poll_with_voters(count)
    hex = SecureRandom.hex(4)
    group = Group.new(name: "Anon#{hex}", group_privacy: 'secret', handle: "anon#{hex}")
    group.creator = (creator = mk_voter("creator", hex))
    group.save!
    Membership.create!(user: creator, group: group, accepted_at: Time.current, admin: true)

    voters = count.times.map { |i| v = mk_voter("v#{i}", hex); Membership.create!(user: v, group: group, accepted_at: Time.current); v }

    poll = PollService.create(params: {
      title: "Anon #{hex}", poll_type: "proposal", group_id: group.id,
      hide_results: 'off', specified_voters_only: false,
      poll_option_names: %w[agree disagree abstain], closing_at: 5.days.from_now
    }, actor: creator)
    poll.update!(anonymous: true)

    voters.each_with_index do |v, i|
      stance = poll.stances.undecided.find_by(participant_id: v.id, latest: true)
      option = poll.poll_options[i % 2]
      StanceService.update(stance: stance, actor: v, params: { stance_choices_attributes: [{ poll_option_id: option.id }] })
    end

    { poll: poll, group: group, voters: voters }
  end

  def mk_voter(name, hex)
    uname = "#{name}#{hex}".delete('_')
    User.create!(name: "#{name}#{hex}", email: "#{name}#{hex}@example.com", username: uname, email_verified: true)
  end
end
