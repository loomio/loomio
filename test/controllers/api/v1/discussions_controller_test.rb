require "test_helper"

class Api::V1::DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  # Test create action
  test "create discussion in group with no notifications" do
    sign_in @user

    post :create, params: { discussion: { title: 'test', group_id: @group.id } }

    assert_response :success
    json = JSON.parse(response.body)
    discussion = Discussion.find(json['discussions'][0]['id'])

    assert_equal 1, discussion.topic_readers.count
    assert_equal @user.id, discussion.topic_readers.first.user_id
    assert_equal 0, discussion.created_event.notifications.count
  end

  test "create discussion without group" do
    sign_in @user

    post :create, params: { discussion: { title: 'test' } }

    assert_response :success
  end

  test "user without groups can create direct discussion when create_user is disabled" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "groupless#{hex}", email: "groupless#{hex}@example.com",
                        username: "groupless#{hex}", email_verified: true,
                        legal_accepted_at: Time.current)
    assert_empty user.groups
    sign_in user

    ENV['FEATURES_DISABLE_CREATE_USER'] = '1'
    post :create, params: { discussion: { title: 'direct thread' } }
    assert_response :success
  ensure
    ENV.delete('FEATURES_DISABLE_CREATE_USER')
  end

  test "user without groups cannot create direct discussion when create_user is enabled" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "groupless#{hex}", email: "groupless#{hex}@example.com",
                        username: "groupless#{hex}", email_verified: true,
                        legal_accepted_at: Time.current)
    assert_empty user.groups
    sign_in user

    ENV.delete('FEATURES_DISABLE_CREATE_USER')
    post :create, params: { discussion: { title: 'direct thread' } }
    assert_response :forbidden
  end

  test "doesnt email everyone on discussion create" do
    sign_in @user

    discussion_params = {
      title: 'discussion title!',
      description: 'From the dawn of internet time...',
      group_id: @group.id,
      private: true
    }

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      post :create, params: { discussion: discussion_params }, format: :json
    end
  end

  test "emails mentioned users on discussion create" do
    sign_in @user

    discussion_params = {
      title: 'discussion title!',
      description: "Hello @#{@admin.username}!",
      description_format: 'md',
      group_id: @group.id,
      private: true
    }

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      post :create, params: { discussion: discussion_params }, format: :json
    end
  end

  test "responds with error when there are unpermitted params" do
    sign_in @user

    discussion_params = {
      title: 'discussion title!',
      group_id: @group.id,
      dontmindme: 'wild wooly byte virus'
    }

    post :create, params: { discussion: discussion_params }

    json = JSON.parse(response.body)
    assert_includes json['exception'], 'ActionController::UnpermittedParameters'
  end

  test "responds with error when user is unauthorized" do
    sign_in @alien

    discussion_params = {
      title: 'discussion title!',
      group_id: @group.id,
      private: true
    }

    post :create, params: { discussion: discussion_params }

    json = JSON.parse(response.body)
    assert_includes json['exception'], 'CanCan::AccessDenied'
  end

  test "responds with validation errors when title is blank" do
    sign_in @user

    discussion_params = {
      title: '',
      group_id: @group.id,
      private: true
    }

    post :create, params: { discussion: discussion_params }, format: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json['errors']['title'], "can't be blank"
  end

  # Test permissions with group settings
  test "cannot start discussion when members_can_start_discussions is false" do
    @group.update(members_can_start_discussions: false)
    sign_in @alien

    post :create, params: { discussion: { title: 'test', group_id: @group.id } }

    assert_response :forbidden
  end

  test "can start discussion when members_can_start_discussions is true" do
    @group.update(members_can_start_discussions: true)
    sign_in @user

    post :create, params: { discussion: { title: 'test', group_id: @group.id } }

    assert_response :success
  end

  test "denies announce discussion when members_can_announce is false" do
    @group.update(members_can_announce: false)
    sign_in @alien

    post :create, params: {
      discussion: {
        title: 'test',
        group_id: @group.id,
        recipient_audience: 'group'
      }
    }

    assert_response :forbidden
  end

  test "allows announce discussion when members_can_announce is true" do
    @group.update(members_can_announce: true)
    sign_in @user

    post :create, params: {
      discussion: {
        title: 'test',
        group_id: @group.id,
        recipient_audience: 'group'
      }
    }

    assert_response :success
  end

  # Test show action
  test "returns discussion json when logged in" do
    sign_in @user

    get :show, params: { id: @discussion.key }

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json.keys, 'users'
    assert_includes json.keys, 'topics'
    assert_includes json.keys, 'discussions'

    discussion_json = json['discussions'][0]
    assert_includes discussion_json.keys, 'id'
    assert_includes discussion_json.keys, 'key'
    assert_includes discussion_json.keys, 'title'
    assert_includes discussion_json.keys, 'description'
  end

  test "does not return a discarded discussion" do
    @discussion.update_columns(discarded_at: 1.day.ago)
    sign_in @user

    get :show, params: { id: @discussion.key }

    json = JSON.parse(response.body)
    assert_nil json['discussions']
  end

  test "returns public discussion when logged out" do
    discussion = discussions(:public_discussion)

    get :show, params: { id: discussion.id }, format: :json

    assert_response :success
    json = JSON.parse(response.body)
    discussion_ids = json['discussions'].map { |d| d['id'] }
    assert_includes discussion_ids, discussion.id
  end

  test "returns unauthorized for private discussion when logged out" do
    get :show, params: { id: @discussion.id }, format: :json

    assert_response :forbidden
  end

  # Test inbox action
  test "inbox responds with forbidden for logged out users" do
    get :inbox

    assert_response :forbidden
  end

  test "inbox returns unread threads" do
    sign_in @user

    # Mark discussion as read
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.viewed!

    # Add a new comment to make it unread
    new_comment = Comment.new(body: "New comment", parent: @discussion, author: @admin)
    CommentService.create(comment: new_comment, actor: @admin)

    get :inbox

    json = JSON.parse(response.body)
    discussion_ids = json['discussions'].map { |d| d['id'] }
    assert_includes discussion_ids, @discussion.id
  end

  test "inbox does not return read threads" do
    sign_in @user

    # Mark all discussions as read
    Discussion.joins(:topic).where(topics: { group_id: @user.group_ids }).find_each do |d|
      TopicReader.for(user: @user, topic: d.topic).viewed!
    end

    get :inbox

    json = JSON.parse(response.body)
    assert_empty json['discussions']
  end

  # Test dashboard action
  test "dashboard responds with forbidden for logged out users" do
    get :dashboard

    assert_response :forbidden
  end

  test "dashboard can filter since a certain date" do
    sign_in @user
    old_discussion = DiscussionService.create(params: { title: "Old thread", group_id: @group.id }, actor: @admin)
    old_discussion.update_columns(created_at: 6.months.ago)

    get :dashboard, params: { since: 3.months.ago }

    json = JSON.parse(response.body)
    ids = json['discussions'].map { |v| v['id'] }
    assert_includes ids, @discussion.id
    refute_includes ids, old_discussion.id
  end

  test "dashboard can filter until a certain date" do
    sign_in @user
    old_discussion = DiscussionService.create(params: { title: "Old thread", group_id: @group.id }, actor: @admin)
    old_discussion.update_columns(created_at: 6.months.ago)

    get :dashboard, params: { until: 3.months.ago }

    json = JSON.parse(response.body)
    ids = json['discussions'].map { |v| v['id'] }
    refute_includes ids, @discussion.id
    assert_includes ids, old_discussion.id
  end

  test "dashboard can limit collection size" do
    sign_in @user

    get :dashboard, params: { per: 2 }

    json = JSON.parse(response.body)
    assert json['discussions'].count <= 2
  end

  # Test update action
  test "updates a discussion" do
    sign_in @user

    post :update, params: { id: @discussion.id, discussion: { title: 'Updated title!', description: 'Updated description' } }, format: :json

    assert_response :success
    assert_equal 'Updated title!', @discussion.reload.title
  end

  test "update responds with validation errors when title is blank" do
    sign_in @user

    put :update, params: { id: @discussion.id, discussion: { title: '' } }, format: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json['errors']['title'], "can't be blank"
  end

  # Test dismiss action
  test "dismiss updates dismissed_at" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.update(volume: TopicReader.volumes[:normal])

    patch :dismiss, params: { id: @discussion.key }

    assert_response :success
    assert_not_nil reader.reload.dismissed_at
  end

  # Test recall action
  test "recall updates dismissed_at to be nil" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.update(volume: TopicReader.volumes[:normal], dismissed_at: 1.day.ago)

    patch :recall, params: { id: @discussion.key }

    assert_response :success
    assert_nil reader.reload.dismissed_at
  end

  # Test close action
  test "allows admins to close a thread" do
    sign_in @admin

    post :close, params: { id: @discussion.id }

    assert_response :success
    assert_not_nil @discussion.topic.reload.closed_at
  end

  test "does not allow non-admins to close a thread" do
    sign_in @alien

    post :close, params: { id: @discussion.id }

    assert_response :forbidden
  end

  test "does not allow logged out users to close a thread" do
    post :close, params: { id: @discussion.id }

    assert_response :forbidden
  end

  # Test reopen action
  test "allows admins to reopen a thread" do
    @discussion.topic.update!(closed_at: 1.day.ago)
    sign_in @admin

    post :reopen, params: { id: @discussion.id }

    assert_response :success
    assert_nil @discussion.topic.reload.closed_at
  end

  test "does not allow non-admins to reopen a thread" do
    @discussion.topic.update!(closed_at: 1.day.ago)
    sign_in @alien

    post :reopen, params: { id: @discussion.id }

    assert_response :forbidden
  end

  # Test pin action
  test "allows admins to pin a thread" do
    sign_in @admin

    post :pin, params: { id: @discussion.id }

    assert_response :success
    assert_not_nil @discussion.topic.reload.pinned_at
  end

  test "allows admins to unpin a thread" do
    @discussion.topic.update!(pinned_at: Time.now)
    sign_in @admin

    post :unpin, params: { id: @discussion.id }

    assert_response :success
    assert_nil @discussion.topic.reload.pinned_at
  end

  test "does not allow non-admins to pin a thread" do
    sign_in @alien

    post :pin, params: { id: @discussion.id }

    assert_response :forbidden
  end

  # Test mark_as_seen action
  test "marks a discussion as seen" do
    discussion = DiscussionService.create(params: { title: "Unseen", group_id: @group.id }, actor: @admin)
    sign_in @user

    assert_difference '@user.topic_readers.count', 1 do
      post :mark_as_seen, params: { id: discussion.id }
    end

    dr = TopicReader.last
    assert_equal discussion, dr.topic.topicable
    assert_not_nil dr.last_read_at
    assert_equal 0, dr.read_items_count
  end

  test "does not allow non-users to mark discussions as seen" do
    post :mark_as_seen, params: { id: @discussion.id }

    assert_response :forbidden
  end

  # Test set_volume action
  test "sets the volume of a thread" do
    sign_in @user
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.update(volume: :loud)

    put :set_volume, params: { id: @discussion.id, volume: :mute }, format: :json

    assert_response :success
    assert_equal :mute, reader.reload.volume.to_sym
  end

  test "does not update volume for unauthorized discussion" do
    sign_in @user

    put :set_volume, params: { id: discussions(:alien_discussion).id, volume: :mute }, format: :json

    refute_equal 200, response.status
  end
end
