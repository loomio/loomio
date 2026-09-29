require 'test_helper'

class Api::V1::PollsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @member = users(:member)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  # Show tests
  test "show displays a poll" do
    poll = PollService.create(params: {
      title: "POLL!",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)

    sign_in @user
    get :show, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['polls'].length
    assert_equal poll.key, json['polls'][0]['key']
  end

  test "show displays voters and score for weighted one point polls while retaining raw scores" do
    poll = PollService.create(params: {
      title: 'Weighted choices', poll_type: 'poll', group_id: @group.id,
      poll_option_names: %w[Yes No], weighted_voting: true,
      closing_at: 3.days.from_now
    }, actor: @admin)
    option = poll.poll_options.find_by!(name: 'Yes')
    poll.stances.latest.find_by!(participant: @user).update!(
      weight: '2.33', cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )
    poll.update_counts!

    sign_in @user
    get :show, params: {id: poll.key}

    assert_response :success
    data = JSON.parse(response.body).fetch('polls').first
    assert_includes data.fetch('result_columns'), 'voter_count'
    assert_includes data.fetch('result_columns'), 'score'
    assert_not_includes data.fetch('result_columns'), 'unweighted_score'
    result = data.fetch('results').find { |row| row['id'] == option.id }
    assert_equal 1, result.fetch('unweighted_score')
    assert_equal 2.33, result.fetch('score')
  end

  test "show serializes without record cache fallbacks" do
    poll = PollService.create(params: {
      title: "cache test poll",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)

    sign_in @user

    assert_no_record_cache_fallbacks do
      get :show, params: { id: poll.key }
    end

    assert_response :success
  end

  test "legacy vote reasons expose plain text and choices without vote metadata" do
    poll = PollService.create(params: {
      title: "Migrated anonymous poll",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now,
      anonymous: true
    }, actor: @admin)
    poll.update_columns(closed_at: Time.current, voting_system: Poll.voting_systems.fetch("anonymous_ballot"))
    sign_in @user
    get :legacy_vote_reasons, params: {id: poll.key}
    assert_response :not_found

    ballot = poll.anonymous_ballots.create!(
      anonymous_ballot_choices_attributes: [
        {poll_option_id: poll.poll_options.first.id, score: 1}
      ]
    )
    LegacyAnonymousVoteReason.create!(
      anonymous_ballot: ballot,
      body: "A plain text legacy reason"
    )

    get :legacy_vote_reasons, params: {id: poll.key}

    assert_response :success
    assert_equal(
      [
        {
          "body" => "A plain text legacy reason",
          "none_of_the_above" => false,
          "choices" => [
            {
              "poll_option_id" => poll.poll_options.first.id,
              "score" => 1
            }
          ]
        }
      ],
      JSON.parse(response.body)
    )
    assert_not_includes response.body, ballot.id
    assert_not_includes response.body, "created_at"

    get :show, params: {id: poll.key}
    serialized_poll = JSON.parse(response.body).fetch("polls").first
    assert_equal 1, serialized_poll["legacy_anonymous_vote_reasons_count"]

    sign_in @alien
    get :legacy_vote_reasons, params: {id: poll.key}
    assert_response :forbidden
  end

  # Index tests
  test "index responds successfully" do
    PollService.create(params: {
      title: "POLL!",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)

    sign_in @user
    get :index
    assert_response :success
  end

  test "index recent includes polls for topic reader guests" do
    hex = SecureRandom.hex(4)
    private_group = Group.create!(name: "Guest poll group #{hex}", handle: "guestpollgroup#{hex}")
    poll_author = User.create!(name: "guestpoll#{hex}", email: "guestpoll#{hex}@example.com", username: "guestpoll#{hex}")
    private_group.add_admin!(poll_author)
    guest_poll = PollService.create(params: {
      title: "Guest poll #{hex}",
      poll_type: "poll",
      private: true,
      group_id: private_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["engage"]
    }, actor: poll_author)
    guest_poll.add_guest!(@user, poll_author)
    private_poll = PollService.create(params: {
      title: "Private poll #{hex}",
      poll_type: "poll",
      private: true,
      group_id: private_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["ignore"]
    }, actor: poll_author)

    sign_in @user
    get :index, params: {
      offset: 0,
      limit: 25,
      order: "id",
      exclude_types: "group reaction",
      status: "recent"
    }

    assert_response :success
    json = JSON.parse(response.body)
    poll_ids = json["polls"].map { |poll| poll["id"] }
    assert_includes poll_ids, guest_poll.id
    refute_includes poll_ids, private_poll.id
  end

  test "index only includes public polls when a group is requested" do
    public_group = groups(:public_group)
    hex = SecureRandom.hex(4)
    poll_author = User.create!(name: "publicpoll#{hex}", email: "publicpoll#{hex}@example.com", username: "publicpoll#{hex}")
    public_group.add_admin!(poll_author)
    public_poll = PollService.create(params: {
      title: "Public poll #{hex}",
      poll_type: "poll",
      private: false,
      group_id: public_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["engage"]
    }, actor: poll_author)

    sign_in @alien
    get :index, params: { status: "recent" }
    assert_response :success
    poll_ids = JSON.parse(response.body)["polls"].map { |poll| poll["id"] }
    refute_includes poll_ids, public_poll.id

    get :index, params: { group_key: public_group.key, status: "recent" }
    assert_response :success
    poll_ids = JSON.parse(response.body)["polls"].map { |poll| poll["id"] }
    assert_includes poll_ids, public_poll.id
  end

  # Create tests
  test "create creates a poll in discussion" do
    thread_count = Topic.where(group_id: @group.id_and_subgroup_ids).count
    @group.update!(subscription: Subscription.create!(owner: @admin, max_threads: thread_count))
    sign_in @admin

    assert_difference 'Poll.count', 1 do
      post :create, params: {
        poll: {
          title: "hello",
          poll_type: "proposal",
          details: "is it me you're looking for?",
          topic_id: @discussion.topic_id,
          group_id: @group.id,
          options: %w[agree abstain disagree],
          weighted_voting: true,
          closing_at: 3.days.from_now.at_beginning_of_hour
        }
      }
    end

    assert_response :success
    poll = Poll.last
    assert_equal "hello", poll.title
    assert_equal @discussion.topic, poll.topic
    assert_equal @admin, poll.author
    assert poll.weighted_voting?
    assert_includes poll.admins, @admin
  end

  test "create standalone poll returns the subscription thread limit message" do
    thread_count = Topic.where(group_id: @group.id_and_subgroup_ids).count
    @group.update!(subscription: Subscription.create!(owner: @admin, max_threads: thread_count))
    sign_in @admin

    assert_no_difference [ 'Poll.count', 'Topic.count' ] do
      post :create, params: {
        poll: {
          title: 'over the limit',
          poll_type: 'proposal',
          group_id: @group.id,
          options: %w[agree disagree],
          closing_at: 3.days.from_now.at_beginning_of_hour
        }
      }
    end

    assert_response :forbidden
    response_json = JSON.parse(response.body)
    assert_equal I18n.t('errors.subscription_thread_limit_reached'), response_json['error']
    assert_equal 'upgrade', response_json['action']
  end

  # Discard tests
  test "discard allows poll author to discard" do
    poll = PollService.create(params: {
      title: "discardable",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)

    sign_in @admin
    delete :discard, params: { id: poll.id }
    assert_response :success

    poll.reload
    assert poll.discarded?
    assert_equal @admin.id, poll.discarded_by
  end

  # Anonymous participation: the electorate is visible to everyone who can see
  # the results, which for anonymous polls means after closing. Membership and
  # invitation details are for members and voters; emails are for group admins.
  test "anonymous votes are hidden from everyone while the poll is open" do
    poll = create_detached_anonymous_poll(title: "open anonymous poll")
    TopicReader.for(user: @user, topic: poll.topic).update!(admin: true)

    [@admin, @user, @member].each do |viewer|
      sign_in viewer
      get :votes, params: {id: poll.key}
      assert_response :forbidden, "#{viewer.name} saw an open anonymous poll's voters"
    end
  end

  test "closed anonymous votes list the electorate for group members without ballot data" do
    @admin.update!(name: 'Test Admin')
    poll = create_detached_anonymous_poll(title: "closed anonymous poll")
    PollService.close(poll: poll, actor: @admin)

    sign_in @user
    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal poll.anonymous_poll_voters.count, json.fetch('meta').fetch('total')
    assert_equal true, json.fetch('meta').fetch('show_voter_details')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    record = json.fetch('voters').find { |voter| voter['voter_id'] == @admin.id }
    assert_equal @admin.avatar_initials, record.fetch('voter_avatar_initials')
    assert record.key?('invited_on')
    assert json.fetch('voters').none? { |voter| voter.key?('voter_email') }
    assert json.fetch('voters').all? { |voter| (voter.keys & %w[stance_id option_scores reason weight anonymous_ballot_id cast_at]).empty? }

    get :votes, params: {id: poll.key, name: @admin.email}
    assert_equal 0, JSON.parse(response.body).fetch('meta').fetch('total')
  end

  test "closed anonymous votes show emails and email search only to group admins" do
    poll = create_detached_anonymous_poll(title: "admin emails")
    TopicReader.for(user: @user, topic: poll.topic).update!(admin: true)
    PollService.close(poll: poll, actor: @admin)

    sign_in @user
    get :votes, params: {id: poll.key}
    assert_equal false, JSON.parse(response.body).fetch('meta').fetch('show_voter_email')

    sign_in @admin
    get :votes, params: {id: poll.key}
    json = JSON.parse(response.body)
    assert_equal true, json.fetch('meta').fetch('show_voter_email')
    assert_equal @user.email, json.fetch('voters').find { |voter| voter['voter_id'] == @user.id }.fetch('voter_email')

    get :votes, params: {id: poll.key, name: @user.email}
    assert_equal [@user.id], JSON.parse(response.body).fetch('voters').pluck('voter_id')
  end

  test "closed anonymous votes stay hidden from people who cannot see the poll" do
    poll = create_detached_anonymous_poll(title: "private anonymous poll")
    PollService.close(poll: poll, actor: @admin)

    sign_in @alien
    get :votes, params: {id: poll.key}
    assert_response :forbidden

    sign_out @alien
    get :votes, params: {id: poll.key}
    assert_response :forbidden
  end

  test "closed public anonymous votes show signed-out visitors names only" do
    group = groups(:public_group)
    group.add_admin!(@admin)
    poll = PollService.create(params: {
      title: "public anonymous poll", poll_type: "proposal", anonymous: true, group_id: group.id,
      poll_option_names: %w[agree disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    PollService.close(poll: poll, actor: @admin)
    assert LoggedOutUser.new.can?(:show, poll)

    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json.fetch('meta').fetch('show_voter_details')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    assert json.fetch('voters').all? { |voter| (voter.keys & %w[member_since inviter_name invited_on voter_email]).empty? }
  end

  test "closed anonymous votes show details to a voter from outside the group" do
    poll = create_detached_anonymous_poll(title: "outside voter")
    PollService.invite(poll: poll, actor: @admin, params: {recipient_emails: [@alien.email]})
    PollService.close(poll: poll, actor: @admin)
    refute @group.members.exists?(@alien.id)
    assert poll.anonymous_poll_voters.exists?(voter_id: @alien.id)

    sign_in @alien
    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json.fetch('meta').fetch('show_voter_details')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
  end

  test "closed direct anonymous votes show names without group details" do
    @discussion.topic.update!(group_id: nil)
    TopicReader.for(user: @admin, topic: @discussion.topic).update!(admin: true, guest: true)
    poll = PollService.create(params: {
      title: "direct anonymous poll", poll_type: "proposal", anonymous: true, specified_voters_only: true,
      topic_id: @discussion.topic_id, poll_option_names: %w[agree disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    PollService.invite(poll: poll, actor: @admin, params: {recipient_user_ids: [@user.id]})
    PollService.close(poll: poll, actor: @admin)

    sign_in @admin
    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json.fetch('voters').pluck('voter_id'), @user.id
    assert_equal false, json.fetch('meta').fetch('show_voter_details')
    assert json.fetch('voters').all? { |voter| !voter.key?('voter_email') }
  end

  test "anonymous participation uses the electorate and preserves invitation dates" do
    poll = create_detached_anonymous_poll(title: "participation source test")
    eligible_voter = poll.anonymous_poll_voters.find_by!(voter: @user)
    invited_at = 2.days.ago.change(usec: 0)
    eligible_voter.update_column(:invited_at, invited_at)
    ([@user] + electorate_except(poll, @user)).first(poll.participation_status_votes_required).each { |voter| create_anonymous_ballot(poll: poll, voter: voter) }
    PollService.close(poll: poll, actor: @admin)
    sign_in @admin

    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    record = json.fetch("voters").find { |receipt| receipt.fetch("voter_id") == @user.id }
    assert_equal invited_at.to_date.iso8601, record.fetch("invited_on")
    assert_equal true, record.fetch("vote_cast")
  end

  test "anonymous participation status appears once the required number have voted" do
    poll = create_detached_anonymous_poll(title: "participation threshold test")
    voters = poll.anonymous_poll_voters.map(&:voter).first(poll.participation_status_votes_required)
    voters.each { |voter| create_anonymous_ballot(poll: poll, voter: voter) }
    PollService.close(poll: poll, actor: @admin)
    sign_in @user

    get :votes, params: { id: poll.key }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json.fetch("meta")["participation_status_visible"]
    assert json.fetch("voters").all? { |receipt| receipt.key?("vote_cast") }
    assert json.fetch("voters").select { |receipt| voters.map(&:id).include?(receipt["voter_id"]) }.all? { |receipt| receipt["vote_cast"] }
  end

  test "anonymous participation status remains hidden when poll closes one vote short" do
    poll = create_detached_anonymous_poll(title: "closed participation threshold test")
    votes_required = poll.participation_status_votes_required
    poll.anonymous_poll_voters.map(&:voter).first(votes_required - 1).each { |voter| create_anonymous_ballot(poll: poll, voter: voter) }
    PollService.close(poll: poll, actor: @admin)

    sign_in @admin
    get :votes, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal false, json.fetch("meta")["participation_status_visible"]
    assert_equal votes_required, json.fetch("meta")["participation_status_votes_required"]
    assert json.fetch("voters").none? { |receipt| receipt.key?("vote_cast") }
  end

  test "anonymous votes search and page the electorate without ballot data" do
    poll = create_detached_anonymous_poll(title: "paged participation")
    PollService.close(poll: poll, actor: @admin)
    sign_in @admin

    get :votes, params: {id: poll.key, name: @user.name, limit: 1, offset: 0}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.fetch('meta').fetch('total')
    assert_equal [@user.id], json.fetch('voters').pluck('voter_id')
    refute json.fetch('voters').first.key?('vote_cast')
    refute json.fetch('voters').first.key?('option_scores')
  end

  test "detached anonymous votes show when each new voter was invited" do
    travel_to Time.zone.parse('2026-09-01 12:00') do
      @poll = create_detached_anonymous_poll(title: "invited on")
      PollService.close(poll: @poll, actor: @admin)
    end

    sign_in @admin
    get :votes, params: {id: @poll.key}

    assert_response :success
    assert JSON.parse(response.body).fetch("voters").all? { |voter| voter["invited_on"] == '2026-09-01' }
  end

  test "detached anonymous votes allow a missing historical inviter" do
    poll = create_detached_anonymous_poll(title: "migrated receipts test")
    poll.anonymous_poll_voters.find_by!(voter: @user).update_column(:inviter_id, nil)
    PollService.close(poll: poll, actor: @admin)

    sign_in @admin
    get :votes, params: {id: poll.key}

    assert_response :success
    details = JSON.parse(response.body).fetch("voters").find { |record| record["voter_id"] == @user.id }
    assert_nil details["inviter_name"]
    assert_equal @user.email, details["voter_email"]
  end

  test "votes lists identified poll voters" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @admin
    get :votes, params: { id: poll.key }
    assert_response :success
    json = JSON.parse(response.body)
    assert_operator json.fetch('meta').fetch('total'), :>, 0
    assert json.fetch('voters').all? { |voter| voter.key?('vote_cast') }
  end

  test "identified votes search without exposing email to an ordinary member" do
    poll = PollService.create(params: {
      title: 'Search voters', poll_type: 'proposal', group_id: @group.id,
      poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    sign_in @user

    get :votes, params: {id: poll.key, name: @admin.name, limit: 1}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.fetch('meta').fetch('total')
    assert_equal [@admin.id], json.fetch('voters').pluck('voter_id')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    assert json.fetch('voters').all? { |voter| !voter.key?('voter_email') }

    get :votes, params: {id: poll.key, name: @admin.email}
    assert_equal 0, JSON.parse(response.body).fetch('meta').fetch('total')
  end

  test "identified votes page through voters invited at the same moment without repeats" do
    poll = PollService.create(params: {
      title: 'Bulk invited voters', poll_type: 'proposal', group_id: @group.id,
      poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    poll.stances.update_all(created_at: Time.zone.parse('2026-09-01 12:00'), cast_at: nil)
    sign_in @admin

    voter_ids = []
    total = nil
    offset = 0
    loop do
      get :votes, params: {id: poll.key, limit: 1, offset: offset}
      json = JSON.parse(response.body)
      total = json.fetch('meta').fetch('total')
      break if offset >= total
      voter_ids.concat(json.fetch('voters').pluck('voter_id'))
      offset += 1
    end

    assert_operator total, :>, 2
    assert_equal poll.stances.latest.pluck(:participant_id).sort, voter_ids.sort
  end

  test "identified votes deny a viewer without access to the poll" do
    poll = PollService.create(params: {
      title: 'Private voters', poll_type: 'proposal', group_id: @group.id,
      poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    sign_in @alien

    get :votes, params: {id: poll.key}

    assert_response :forbidden
  end

  test "identified public poll votes omit private voter details for an outside viewer" do
    poll = Poll.create!(
      title: 'Public voters', poll_type: 'proposal', topic: discussions(:public_discussion).topic,
      author: @admin, poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    )
    Stance.create!(poll: poll, participant: @user, inviter: @admin)
    sign_in @alien

    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json.fetch('meta').fetch('show_voter_details')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    assert json.fetch('voters').all? { |voter| !voter.key?('member_since') && !voter.key?('voter_email') }
  end

  test "identified direct-topic votes do not use group voter details" do
    poll = Poll.create!(
      title: 'Direct voters', poll_type: 'proposal', topic: topics(:direct_topic),
      author: @admin, poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    )
    Stance.create!(poll: poll, participant: @admin, inviter: @admin)
    sign_in @admin

    get :votes, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json.fetch('meta').fetch('show_voter_details')
    assert_equal false, json.fetch('meta').fetch('show_voter_email')
    assert json.fetch('voters').all? { |voter| !voter.key?('member_since') && !voter.key?('voter_email') }
  end

  test "identified votes include the assigned weight when enabled" do
    poll = PollService.create(params: {
      title: 'Weighted voters', poll_type: 'proposal', group_id: @group.id,
      poll_option_names: %w[Agree Disagree], weighted_voting: true,
      closing_at: 5.days.from_now
    }, actor: @admin)
    poll.stances.latest.find_by!(participant: @user).update!(weight: '2.5')
    sign_in @admin

    get :votes, params: {id: poll.key, name: @user.name}

    assert_response :success
    row = JSON.parse(response.body).fetch('voters').sole
    assert_equal @user.id, row.fetch('voter_id')
    assert_equal '2.5', row.fetch('weight')
  end

  test "identified votes hide choices and ignore option filtering until the viewer votes" do
    poll = PollService.create(params: {
      title: 'Hidden results', poll_type: 'proposal', group_id: @group.id,
      hide_results: 'until_vote', poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    option = poll.poll_options.first
    stance = poll.stances.latest.find_by!(participant: @admin)
    stance.update!(cast_at: Time.current, stance_choices_attributes: [{poll_option_id: option.id, score: 1}])
    sign_in @user

    get :votes, params: {id: poll.key, poll_option_id: option.id}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal poll.stances.latest.count, json.fetch('meta').fetch('total')
    assert json.fetch('voters').none? { |voter| voter.key?('option_scores') }

    sign_in @admin
    get :votes, params: {id: poll.key, poll_option_id: option.id}
    assert_response :success
    visible = JSON.parse(response.body)
    assert_equal 1, visible.fetch('meta').fetch('total')
    assert_equal({option.id.to_s => 1}, visible.fetch('voters').sole.fetch('option_scores'))
  end

  test "identified votes in a hidden-until-closed poll show only the viewer's row while open" do
    poll = PollService.create(params: {
      title: 'Closed results only', poll_type: 'proposal', group_id: @group.id,
      hide_results: 'until_closed', poll_option_names: %w[Agree Disagree], closing_at: 5.days.from_now
    }, actor: @admin)
    option = poll.poll_options.first
    poll.stances.latest.find_by!(participant: @admin).update!(
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )
    sign_in @user

    get :votes, params: {id: poll.key, poll_option_id: option.id}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal [@user.id], json.fetch('voters').pluck('voter_id')
    refute json.fetch('voters').first.key?('option_scores')
  end

  # Close tests
  test "close closes an open poll" do
    poll = PollService.create(params: {
      title: "closeable",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @admin
    post :close, params: { id: poll.id }
    assert_response :success

    poll.reload
    assert poll.closed?
  end

  private

  def create_detached_anonymous_poll(title:)
    PollService.create(params: {
      title: title,
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)
  end

  def electorate_except(poll, user)
    poll.anonymous_poll_voters.where.not(voter_id: user.id).map(&:voter)
  end

  def create_anonymous_ballot(poll:, voter:)
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id, score: 1 }]
      ),
      actor: voter
    )
  end
end
