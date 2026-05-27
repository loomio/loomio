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
    assert_response :bad_request
  end

  test "responds with error when user is unauthorized" do
    sign_in @alien

    discussion_params = {
      title: 'discussion title!',
      group_id: @group.id,
      private: true
    }

    post :create, params: { discussion: discussion_params }
    assert_response :forbidden
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

  test "show serializes without record cache fallbacks" do
    sign_in @user
    Reaction.create!(reactable: @discussion, user: @alien, reaction: ':heart:')

    assert_no_record_cache_fallbacks do
      get :show, params: { id: @discussion.key }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json['reactions'].map { |r| r['id'] }, Reaction.last.id
  end

  test "does not return a discarded discussion" do
    @discussion.topic.update_columns(discarded_at: 1.day.ago)
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

end
