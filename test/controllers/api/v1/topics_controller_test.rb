require "test_helper"

class Api::V1::TopicsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    @topic = @discussion.topic
  end

  # Test index action
  test "index responds with success for logged out users" do
    get :index

    assert_response :success
  end

  test "index returns topics for current user groups" do
    sign_in @user

    get :index

    assert_response :success
    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    assert_includes topic_ids, @topic.id
  end

  test "index serializes without record cache fallbacks" do
    sign_in @user

    assert_no_record_cache_fallbacks do
      get :index
    end

    assert_response :success
  end

  test "index does not return topics from groups user is not a member of" do
    sign_in @alien

    get :index

    assert_response :success
    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    refute_includes topic_ids, @topic.id
  end

  test "index only includes public topics when a group is requested" do
    public_group = groups(:public_group)
    hex = SecureRandom.hex(4)
    public_author = User.create!(name: "publictopic#{hex}", email: "publictopic#{hex}@example.com", username: "publictopic#{hex}")
    public_group.add_admin!(public_author)
    discussion = DiscussionService.build(params: {
      title: "Public topic #{hex}",
      group_id: public_group.id,
      private: false,
      description_format: "html"
    }, actor: public_author)
    discussion.save(validate: false)
    discussion.create_missing_created_event!

    sign_in @alien
    get :index
    assert_response :success
    topic_ids = JSON.parse(response.body)['topics'].map { |t| t['id'] }
    refute_includes topic_ids, discussion.topic.id

    get :index, params: { group_id: public_group.id }
    assert_response :success
    topic_ids = JSON.parse(response.body)['topics'].map { |t| t['id'] }
    assert_includes topic_ids, discussion.topic.id
  end

  test "index returns guest topics" do
    sign_in @alien
    @topic.add_guest!(@alien, @admin)

    get :index

    assert_response :success
    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    assert_includes topic_ids, @topic.id
  end

  test "index orders by last_activity_at desc" do
    sign_in @user
    older = DiscussionService.create(params: { title: "Older", group_id: @group.id }, actor: @admin)
    newer = DiscussionService.create(params: { title: "Newer", group_id: @group.id }, actor: @admin)
    older.topic.update_column(:last_activity_at, 2.days.ago)
    newer.topic.update_column(:last_activity_at, 1.minute.ago)

    get :index

    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    older_idx = topic_ids.index(older.topic.id)
    newer_idx = topic_ids.index(newer.topic.id)
    assert newer_idx < older_idx, "newer topic should appear before older topic"
  end

  test "index respects per param" do
    sign_in @user

    get :index, params: { per: 1 }

    json = JSON.parse(response.body)
    assert_equal 1, json['topics'].count
  end

  test "index returns total topic count in meta" do
    sign_in @user
    DiscussionService.create(params: { title: "Another discussion", group_id: @group.id }, actor: @admin)

    get :index, params: { group_id: @group.id, topicable_type: 'Discussion', per: 1 }

    json = JSON.parse(response.body)
    assert_equal 1, json['topics'].count
    assert_operator json['meta']['total'], :>, json['topics'].count
  end

  test "index respects from param" do
    sign_in @user

    get :index
    all_json = JSON.parse(response.body)
    all_ids = all_json['topics'].map { |t| t['id'] }

    get :index, params: { from: 1 }
    offset_json = JSON.parse(response.body)
    offset_ids = offset_json['topics'].map { |t| t['id'] }

    assert_equal all_ids[1], offset_ids[0] if all_ids.length > 1
  end

  test "index excludes topics with discarded discussions" do
    sign_in @user
    discussion = DiscussionService.create(params: { title: "Soon discarded", group_id: @group.id }, actor: @admin)
    topic_id = discussion.topic.id
    TopicService.discard(topic: discussion.topic, actor: @admin)

    get :index

    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    refute_includes topic_ids, topic_id
  end

  test "index excludes topics with discarded polls" do
    sign_in @user
    poll = PollService.create(params: {
      title: "Soon discarded",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group_id: @group.id,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @admin)
    topic_id = poll.topic.id
    TopicService.discard(topic: poll.topic, actor: @admin)

    get :index

    json = JSON.parse(response.body)
    topic_ids = json['topics'].map { |t| t['id'] }
    refute_includes topic_ids, topic_id
  end

  # Test dismiss action
  test "dismiss updates dismissed_at" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @topic)
    reader.update(volume: TopicReader.volumes[:normal])

    patch :dismiss, params: { id: @topic.id }

    assert_response :success
    assert_not_nil reader.reload.dismissed_at
  end

  # Test recall action
  test "recall updates dismissed_at to be nil" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @topic)
    reader.update(volume: TopicReader.volumes[:normal], dismissed_at: 1.day.ago)

    patch :recall, params: { id: @topic.id }

    assert_response :success
    assert_nil reader.reload.dismissed_at
  end

  # Test lock action
  test "allows admins to lock a thread" do
    sign_in @admin

    patch :lock, params: { id: @topic.id }

    assert_response :success
    assert_not_nil @topic.reload.locked_at
  end

  test "does not allow non-members to lock a thread" do
    sign_in @alien

    patch :lock, params: { id: @topic.id }

    assert_response :forbidden
  end

  test "does not allow logged out users to lock a thread" do
    patch :lock, params: { id: @topic.id }

    assert_response :unauthorized
  end

  # Test unlock action
  test "allows admins to unlock a thread" do
    @topic.update!(locked_at: 1.day.ago)
    sign_in @admin

    patch :unlock, params: { id: @topic.id }

    assert_response :success
    assert_nil @topic.reload.locked_at
  end

  test "does not allow non-members to unlock a thread" do
    @topic.update!(locked_at: 1.day.ago)
    sign_in @alien

    patch :unlock, params: { id: @topic.id }

    assert_response :forbidden
  end

  # Test pin action
  test "allows admins to pin a thread" do
    sign_in @admin

    patch :pin, params: { id: @topic.id }

    assert_response :success
    assert_not_nil @topic.reload.pinned_at
  end

  test "allows admins to unpin a thread" do
    @topic.update!(pinned_at: Time.now)
    sign_in @admin

    patch :unpin, params: { id: @topic.id }

    assert_response :success
    assert_nil @topic.reload.pinned_at
  end

  test "does not allow non-members to pin a thread" do
    sign_in @alien

    patch :pin, params: { id: @topic.id }

    assert_response :forbidden
  end

  # Test mark_as_read action
  test "marks a topic as read with range string" do
    discussion = DiscussionService.create(params: { title: "Unread", group_id: @group.id }, actor: @admin)
    comment = CommentService.create(comment: Comment.new(body: "hello", parent: discussion, author: @admin), actor: @admin)
    sign_in @user

    patch :mark_as_read, params: { id: discussion.topic.id, ranges: "1-1" }

    assert_response :success
    reader = TopicReader.for(user: @user, topic: discussion.topic)
    assert_equal [[1, 1]], reader.read_ranges
  end

  test "marks a topic as read with multi-range string" do
    discussion = DiscussionService.create(params: { title: "Unread", group_id: @group.id }, actor: @admin)
    3.times { CommentService.create(comment: Comment.new(body: "hello", parent: discussion, author: @admin), actor: @admin) }
    sign_in @user

    patch :mark_as_read, params: { id: discussion.topic.id, ranges: "1-2,3-3" }

    assert_response :success
    reader = TopicReader.for(user: @user, topic: discussion.topic)
    assert_equal [[1, 3]], reader.read_ranges
  end

  test "does not allow non-members to mark as read" do
    sign_in @alien

    patch :mark_as_read, params: { id: @topic.id, ranges: "1-1" }

    assert_response :success # returns success but doesn't create reader due to ability check
  end

  # Test mark_as_seen action
  test "marks a topic as seen" do
    discussion = DiscussionService.create(params: { title: "Unseen", group_id: @group.id }, actor: @admin)
    sign_in @user

    assert_difference '@user.topic_readers.count', 1 do
      patch :mark_as_seen, params: { id: discussion.topic.id }
    end

    dr = TopicReader.last
    assert_equal discussion, dr.topic.topicable
    assert_not_nil dr.last_read_at
    assert_equal 1, dr.read_items_count  # root event (sequence_id 0) is marked as read
  end

  test "does not allow non-users to mark topics as seen" do
    patch :mark_as_seen, params: { id: @topic.id }

    assert_response :unauthorized
  end

  # Test set_volume action
  test "sets the volume of a topic" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @topic)
    reader.update(volume: :loud)

    patch :set_volume, params: { id: @topic.id, volume: :mute }

    assert_response :success
    assert_equal :mute, reader.reload.volume.to_sym
  end

  test "does not update volume for unauthorized topic" do
    sign_in @user

    patch :set_volume, params: { id: discussions(:alien_discussion).topic.id, volume: :mute }

    refute_equal 200, response.status
  end

  # Test history action
  test "history returns readers and sideloaded users" do
    sign_in @admin
    TopicReader.find_or_initialize_by(user: @user, topic: @topic).update!(last_read_at: 1.hour.ago, volume: :normal)

    get :history, params: { id: @topic.id }

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json['data'].map { |r| r['user_id'] }, @user.id
    assert_includes json['users'].map { |u| u['id'] }, @user.id
  end

  test "history excludes readers who have not read the topic" do
    sign_in @admin
    TopicReader.where(user: @user, topic: @topic).delete_all

    get :history, params: { id: @topic.id }

    assert_response :success
    json = JSON.parse(response.body)
    refute_includes json['data'].map { |r| r['user_id'] }, @user.id
  end

  test "history returns 403 when topic has an anonymous poll" do
    sign_in @user
    poll = Poll.new(title: "Secret vote", poll_type: "proposal", topic: @topic,
                    anonymous: true, opened_at: Time.now, closing_at: 1.day.from_now, author: @admin)
    poll.poll_options.build(name: 'agree')
    poll.poll_options.build(name: 'disagree')
    poll.save!

    get :history, params: { id: @topic.id }

    assert_response :forbidden
  end

  test "history denied to non-members" do
    sign_in @alien

    get :history, params: { id: @topic.id }

    assert_response :forbidden
  end

  test "history requires sign in" do
    get :history, params: { id: @topic.id }

    assert_response :unauthorized
  end
end
