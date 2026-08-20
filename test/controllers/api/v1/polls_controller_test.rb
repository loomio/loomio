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
      from: 0,
      per: 25,
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
          closing_at: 3.days.from_now.at_beginning_of_hour
        }
      }
    end

    assert_response :success
    poll = Poll.last
    assert_equal "hello", poll.title
    assert_equal @discussion.topic, poll.topic
    assert_equal @admin, poll.author
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

  # Receipts tests
  test "receipts returns receipts for a poll" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @admin
    get :receipts, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal poll.title, json['poll_title']
    assert json.key?('receipts')
  end

  test "anonymous participation status is hidden until three people vote" do
    poll = create_detached_anonymous_poll(title: "participation threshold test")
    sign_in @admin

    [@admin, @user, @member].each_with_index do |voter, votes_count|
      get :receipts, params: { id: poll.key }
      assert_response :success

      json = JSON.parse(response.body)
      assert_equal false, json["participation_status_visible"], "status was visible after #{votes_count} votes"
      assert_equal 3, json["participation_status_votes_min"]
      assert json.fetch("receipts").none? { |receipt| receipt.key?("vote_cast") }

      create_anonymous_ballot(poll: poll, voter: voter)
    end

    get :receipts, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["participation_status_visible"]
    assert json.fetch("receipts").all? { |receipt| receipt.key?("vote_cast") }
    voter_ids = [@admin.id, @user.id, @member.id]
    voter_receipts = json.fetch("receipts").select { |receipt| voter_ids.include?(receipt["voter_id"]) }
    assert voter_receipts.all? { |receipt| receipt["vote_cast"] }
  end

  test "anonymous participation status remains hidden when poll closes with two votes" do
    poll = create_detached_anonymous_poll(title: "closed participation threshold test")
    create_anonymous_ballot(poll: poll, voter: @admin)
    create_anonymous_ballot(poll: poll, voter: @user)
    PollService.close(poll: poll, actor: @admin)

    sign_in @admin
    get :receipts, params: { id: poll.key }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal false, json["participation_status_visible"]
    assert_equal 3, json["participation_status_votes_min"]
    assert json.fetch("receipts").none? { |receipt| receipt.key?("vote_cast") }
  end

  test "detached anonymous receipts denied for non-admin member" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @user
    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  end

  test "detached anonymous receipts allow a missing historical inviter" do
    poll = PollService.create(params: {
      title: "migrated receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)
    poll.anonymous_poll_voters.find_by!(voter: @user).update_column(:inviter_id, nil)

    sign_in @admin
    get :receipts, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["show_voter_email"]
    receipt = json.fetch("receipts").find { |record| record["voter_id"] == @user.id }
    assert_nil receipt["inviter_id"]
    assert_nil receipt["inviter_name"]
    assert_equal @user.email, receipt["voter_email"]
  end

  test "direct-topic coordinator cannot verify participants" do
    @discussion.topic.update!(group_id: nil)
    TopicReader.for(user: @admin, topic: @discussion.topic).update!(admin: true, guest: true)
    poll = PollService.create(params: {
      title: "direct receipts test",
      poll_type: "proposal",
      anonymous: true,
      specified_voters_only: true,
      topic_id: @discussion.topic_id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)
    PollService.invite(
      poll: poll,
      actor: @admin,
      params: {recipient_user_ids: [@user.id]}
    )

    sign_in @admin
    get :receipts, params: {id: poll.key}

    assert_response :forbidden
  end

  test "group poll coordinator verifies participation without participant emails" do
    poll = PollService.create(params: {
      title: "coordinator receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)
    TopicReader.for(user: @user, topic: poll.topic).update!(admin: true)

    sign_in @user
    get :receipts, params: {id: poll.key}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json["show_voter_email"]
    assert json.fetch("receipts").all? { |receipt| receipt["voter_email"].nil? }
  end

  test "detached anonymous receipts denied for poll member who is not a group member" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      specified_voters_only: true,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)
    AnonymousPollVoter.create!(
      poll: poll,
      voter: @alien,
      inviter: @admin,
      group_member: false
    )

    sign_in @alien
    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  end

  test "receipts denied for non-member by default" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @alien
    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  end

  test "receipts denied for signed out users" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  end

  test "receipts denied for non-admin member when admin only env set" do
    ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY'] = '1'

    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @user
    get :receipts, params: { id: poll.key }
    assert_response :forbidden
  ensure
    ENV.delete('LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY')
  end

  test "receipts allowed for group admin when admin only env set" do
    ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY'] = '1'

    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      anonymous: true,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @admin
    get :receipts, params: { id: poll.key }
    assert_response :success
  ensure
    ENV.delete('LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY')
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

  def create_anonymous_ballot(poll:, voter:)
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id, score: 1 }]
      ),
      actor: voter
    )
  end
end
