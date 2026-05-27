require 'test_helper'

class Api::V1::PollsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
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
    Reaction.create!(reactable: poll, user: @alien, reaction: ':heart:')

    assert_no_record_cache_fallbacks do
      get :show, params: { id: poll.key }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json['reactions'].map { |r| r['id'] }, Reaction.last.id
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

  test "receipts allowed for non-admin member by default" do
    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain],
      closing_at: 5.days.from_now
    }, actor: @admin)

    sign_in @user
    get :receipts, params: { id: poll.key }
    assert_response :success
  end

  test "receipts denied for non-admin member when admin only env set" do
    ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY'] = '1'

    poll = PollService.create(params: {
      title: "receipts test",
      poll_type: "proposal",
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
end
