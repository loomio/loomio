require 'test_helper'

class Api::V1::StancesControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @group = groups(:group)
    @group.update!(vote_weights_allowed: true)

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

  test "identified votes include the former verification details for the current page" do
    sign_in @admin

    get :index, params: {poll_id: @poll.id, per: 1, from: 0}

    assert_response :success
    json = JSON.parse(response.body)
    first_stance = json.fetch('stances').first
    details = json.fetch('meta').fetch('voter_details_by_user_id')
    assert_equal [first_stance.fetch('participant_id').to_s], details.keys
    assert_equal true, json.fetch('meta').fetch('show_voter_email')
    assert_equal true, json.fetch('meta').fetch('show_voter_details')
    assert details.values.first.key?('member_since')
    assert details.values.first.key?('inviter_name')
    assert details.values.first.key?('invited_on')
    assert details.values.first.key?('voter_email')
  end

  test "identified vote details do not expose email to an ordinary voter" do
    sign_in @user

    get :index, params: {poll_id: @poll.id, per: 1}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    assert_equal true, json.fetch('meta').fetch('show_voter_details')
    assert json.fetch('meta').fetch('voter_details_by_user_id').values.all? { |details| !details.key?('voter_email') }
  end

  test "unweighted identified votes serialize the effective weight of one" do
    stance = @poll.stances.latest.find_by!(participant: @user)
    stance.update!(weight: '2.33')
    sign_in @admin

    get :index, params: {poll_id: @poll.id}

    assert_response :success
    serialized_stance = JSON.parse(response.body).fetch('stances').find { |item| item['id'] == stance.id }
    assert_equal '1', serialized_stance.fetch('weight')
    assert_equal '1', HasVoteWeight.format(stance.reload.weight)
  end

  test "voter management pages users and only includes weights for that page" do
    @poll.update_column(:vote_weights_enabled, true)
    sign_in @admin

    get :users, params: {poll_id: @poll.id, per: 1, from: 0}
    first = JSON.parse(response.body)
    get :users, params: {poll_id: @poll.id, per: 1, from: 1}
    second = JSON.parse(response.body)

    assert_response :success
    assert_operator first.fetch('meta').fetch('total'), :>, 1
    refute_equal first.fetch('users').first.fetch('id'), second.fetch('users').first.fetch('id')
    assert_equal first.fetch('users').map { |user| user.fetch('id').to_s }.sort, first.fetch('meta').fetch('weights_by_user_id').keys.sort
    assert_equal second.fetch('users').map { |user| user.fetch('id').to_s }.sort, second.fetch('meta').fetch('weights_by_user_id').keys.sort
  end

  test "voter management lists newly added voters first even after another voter revises a vote" do
    new_voter = users(:alien)
    @group.add_member!(new_voter)
    PollService.invite(poll: @poll, actor: @admin, params: {recipient_user_ids: [new_voter.id], notify_recipients: false})
    sign_in @admin

    get :users, params: {poll_id: @poll.id}
    assert_equal new_voter.id, JSON.parse(response.body).fetch('users').first.fetch('id')

    older_stance = @poll.stances.latest.where.not(participant_id: new_voter.id).order(:id).first
    replacement = older_stance.build_replacement
    older_stance.update!(latest: false)
    replacement.save!

    get :users, params: {poll_id: @poll.id}
    assert_equal new_voter.id, JSON.parse(response.body).fetch('users').first.fetch('id')
  end

  test "voter management lists newly added anonymous poll voters first" do
    poll = create_detached_anonymous_poll
    new_voter = users(:alien)
    @group.add_member!(new_voter)
    PollService.invite(poll: poll, actor: @admin, params: {recipient_user_ids: [new_voter.id], notify_recipients: false})
    sign_in @admin

    get :users, params: {poll_id: poll.id}

    assert_response :success
    assert_equal new_voter.id, JSON.parse(response.body).fetch('users').first.fetch('id')
  end

  test "non coordinator cannot page through voter management" do
    sign_in users(:alien)

    get :users, params: {poll_id: @poll.id, per: 1}

    assert_response :forbidden
  end

  test "poll admin updates stance weight before voting opens" do
    @poll.update_columns(opened_at: nil, closing_at: nil, vote_weights_enabled: true)
    stance = @poll.stances.latest.find_by!(participant: @user)
    sign_in @admin

    patch :set_weight, params: {id: stance.id, weight: 0}

    assert_response :success
    assert_equal 0, stance.reload.weight
  end

  test "poll admin sets a fractional stance weight" do
    @poll.update_columns(opened_at: nil, closing_at: nil, vote_weights_enabled: true)
    stance = @poll.stances.latest.find_by!(participant: @user)
    sign_in @admin

    patch :set_weight, params: {id: stance.id, weight: '0.5'}

    assert_response :success
    assert_equal BigDecimal('0.5'), stance.reload.weight
  end

  test "poll admin cannot set stance weights when vote weights are disabled" do
    stance = @poll.stances.latest.find_by!(participant: @user)
    sign_in @admin

    patch :set_weight, params: {id: stance.id, weight: 2}

    assert_response :forbidden
    assert_equal 1, stance.reload.weight
  end

  test "poll admin updates stance weight after voting opens" do
    @poll.update_column(:vote_weights_enabled, true)
    stance = @poll.stances.latest.find_by!(participant: @user)
    sign_in @admin

    patch :set_weight, params: {id: stance.id, weight: 0}

    assert_response :success
    assert_equal 0, stance.reload.weight
  end

  test "poll admin cannot update stance weight after voting closes" do
    stance = @poll.stances.latest.find_by!(participant: @user)
    @poll.update_columns(vote_weights_enabled: true, closed_at: Time.current)
    sign_in @admin

    patch :set_weight, params: {id: stance.id, weight: 0}

    assert_response :forbidden
    assert_equal 1, stance.reload.weight
  end

  test "poll admin resets every voter weight" do
    @poll.update_column(:vote_weights_enabled, true)
    sign_in @admin

    patch :reset_weights, params: {poll_id: @poll.id, weight: '2.33'}

    assert_response :success
    assert @poll.stances.latest.all? { |stance| stance.reload.weight == BigDecimal('2.33') }
  end

  test "poll admin restores current member weights and defaults other voters to one" do
    @poll.update_column(:vote_weights_enabled, true)
    @group.membership_for(@user).update!(weight: '2.33')
    option = @poll.poll_options.first
    member_stance = @poll.stances.latest.find_by!(participant: @user)
    member_stance.update!(weight: '0.5', cast_at: Time.current,
                          stance_choices_attributes: [{poll_option_id: option.id, score: 1}])
    guest = User.create!(name: 'Guest voter', email: "guest-voter-#{SecureRandom.hex(4)}@example.test")
    guest_stance = Stance.create!(poll: @poll, participant: guest, inviter: @admin, weight: 3)
    sign_in @admin

    patch :reset_weights, params: {poll_id: @poll.id, mode: 'membership'}

    assert_response :success
    assert_equal BigDecimal('2.33'), member_stance.reload.weight
    assert_equal 1, guest_stance.reload.weight
    assert_equal BigDecimal('2.33'), option.reload.total_score
  end

  test "voter cannot reset poll weights" do
    @poll.update_column(:vote_weights_enabled, true)

    patch :reset_weights, params: {poll_id: @poll.id, weight: '0.5'}

    assert_response :forbidden
    assert @poll.stances.latest.all? { |stance| stance.reload.weight == 1 }
  end

  test "poll admin cannot reset weights after closing" do
    @poll.update_columns(vote_weights_enabled: true, closed_at: Time.current)
    sign_in @admin

    patch :reset_weights, params: {poll_id: @poll.id, weight: '0.5'}

    assert_response :forbidden
    assert @poll.stances.latest.all? { |stance| stance.reload.weight == 1 }
  end

  test "poll admin cannot reset weights on an anonymous poll" do
    @poll.update_columns(vote_weights_enabled: true, anonymous: true, voting_system: Poll.voting_systems.fetch('anonymous_ballot'))
    sign_in @admin

    patch :reset_weights, params: {poll_id: @poll.id, weight: '0.5'}

    assert_response :forbidden
    assert @poll.stances.latest.all? { |stance| stance.reload.weight == 1 }
  end

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

  test "index returns voter rows with a total for paginated votes" do
    sign_in @admin

    get :index, params: {poll_id: @poll.id, per: 1, from: 0}
    first = JSON.parse(response.body)
    get :index, params: {poll_id: @poll.id, per: 1, from: 1}
    second = JSON.parse(response.body)

    assert_response :success
    assert_equal @poll.stances.latest.count, first.fetch('meta').fetch('total')
    assert_equal first.fetch('meta').fetch('total'), second.fetch('meta').fetch('total')
    assert_equal 1, first.fetch('stances').length
    assert_equal 1, second.fetch('stances').length
    refute_equal first.fetch('stances').first.fetch('id'), second.fetch('stances').first.fetch('id')
  end

  test "stance weight is visible to viewers of identified polls" do
    @poll.update_column(:vote_weights_enabled, true)
    weighted_stance = @poll.stances.latest.find_by!(participant: @user)
    weighted_stance.update!(weight: 2)

    sign_in @admin
    get :index, params: {poll_id: @poll.id}
    admin_stance = JSON.parse(response.body).fetch('stances').find { |stance| stance['id'] == weighted_stance.id }
    assert_equal '2', admin_stance.fetch('weight')

    sign_in users(:alien)
    discussions(:public_discussion).topic.group.update!(vote_weights_allowed: true)
    public_poll = Poll.create!(
      title: 'Public weighted poll',
      poll_type: 'proposal',
      topic: discussions(:public_discussion).topic,
      author: @admin,
      vote_weights_enabled: true,
      poll_option_names: ['Agree', 'Disagree'],
      closing_at: 1.day.from_now
    )
    public_stance = Stance.create!(poll: public_poll, participant: @user, weight: 2)
    get :index, params: {poll_id: public_poll.id}
    response_json = JSON.parse(response.body)
    viewer_stance = response_json.fetch('stances').find { |stance| stance['id'] == public_stance.id }
    assert_equal '2', viewer_stance.fetch('weight')
    assert_equal false, response_json.fetch('meta').fetch('show_voter_details')
    assert_not response_json.fetch('meta').key?('voter_details_by_user_id')
  end

  test "my_stances serializes the filtered collection" do
    sign_in @admin

    get :my_stances

    assert_response :success
    stance_ids = JSON.parse(response.body).fetch('stances').pluck('id')
    assert_includes stance_ids, @poll.stances.find_by!(participant_id: @admin.id).id
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

  test "vote without a timeline item returns the saved stance" do
    sign_in @user
    stance = @poll.stances.find_by!(participant_id: @user.id)

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [ { poll_option_id: @poll.poll_options.first.id } ],
        reason: ""
      }
    }

    assert_response :success
    payload = JSON.parse(response.body)
    saved_stance = payload.fetch("stances").find { |record| record["id"] == stance.id }
    assert saved_stance.fetch("cast_at")
    assert_not payload.key?("topic_items")
  end

  test "in-place update returns the existing topic item with the updated stance" do
    sign_in @user
    stance = @poll.stances.find_by!(participant_id: @user.id)
    option = @poll.poll_options.first

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [ { poll_option_id: option.id } ],
        reason: "Initial response"
      }
    }
    assert_response :success
    topic_item = TopicItem.find_by!(itemable: stance, kind: "stance_created")

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [ { poll_option_id: option.id } ],
        reason: "Edited response"
      }
    }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [ topic_item.id ], payload.fetch("topic_items").pluck("id")
    assert_equal "Edited response", payload.fetch("stances").find { |record| record["id"] == stance.id }.fetch("reason")
  end

  test "update requires a reason when disagreeing" do
    @poll.update!(stance_reason_required: "required_for_disagree_or_block")
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
    @poll.update!(stance_reason_required: "required_for_disagree_or_block")
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

  test "rejects contradictory proposal choices and negative scores" do
    sign_in @user
    stance = @poll.stances.find_by!(participant_id: @user.id)

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: @poll.poll_options.map do |option|
          { poll_option_id: option.id, score: option == @poll.poll_options.first ? 1 : -2 }
        end
      }
    }

    assert_response :unprocessable_entity
    assert_nil stance.reload.cast_at
    assert_empty stance.stance_choices
    assert_equal [0, 0], @poll.reload.stance_counts
  end

  test "rejects duplicate options as invalid ballot input" do
    sign_in @user
    stance = @poll.stances.find_by!(participant_id: @user.id)
    option = @poll.poll_options.first

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [
          { poll_option_id: option.id, score: 1 },
          { poll_option_id: option.id, score: 1 }
        ]
      }
    }

    assert_response :unprocessable_entity
    assert_nil stance.reload.cast_at
    assert_empty stance.stance_choices
    assert_equal [0, 0], @poll.reload.stance_counts
  end

  test "rejects options belonging to another poll as invalid ballot input" do
    other_poll = PollService.create(params: {
      title: "Other proposal",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now
    }, actor: @admin)
    sign_in @user
    stance = @poll.stances.find_by!(participant_id: @user.id)

    post :update, params: {
      id: stance.id,
      stance: {
        poll_id: @poll.id,
        stance_choices_attributes: [
          { poll_option_id: other_poll.poll_options.first.id, score: 1 }
        ]
      }
    }

    assert_response :unprocessable_entity
    assert_nil stance.reload.cast_at
    assert_empty stance.stance_choices
    assert_equal [0, 0], @poll.reload.stance_counts
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

end
