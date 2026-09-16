require "test_helper"

class Api::V1::DiscussionsControllerTest < ActionController::TestCase
  inline_jobs "emails mentioned users on discussion create"
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  # Test create action
  test "create discussion in group with no recipient notification" do
    sign_in @user

    post :create, params: { discussion: { title: 'test', group_id: @group.id } }

    assert_response :success
    json = JSON.parse(response.body)
    discussion = Discussion.find(json['discussions'][0]['id'])

    assert_equal 1, discussion.topic_readers.count
    assert_equal @user.id, discussion.topic_readers.first.user_id
    assert_not Notification.about(discussion).exists?(kind: "new_discussion")
  end

  test "create returns the subscription thread limit message" do
    @discussion.topic.update!(discarded_at: Time.current)
    thread_count = Topic.where(group_id: @group.id_and_subgroup_ids).count
    @group.update!(subscription: Subscription.create!(owner: @user, max_threads: thread_count))
    sign_in @user

    assert_no_difference [ 'Discussion.count', 'Topic.count' ] do
      post :create, params: { discussion: { title: 'over the limit', group_id: @group.id } }
    end

    assert_response :forbidden
    response_json = JSON.parse(response.body)
    assert_equal I18n.t('errors.subscription_thread_limit_reached'), response_json['error']
    assert_equal 'upgrade', response_json['action']
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

    deliveries_before = ActionMailer::Base.deliveries.count
    post :create, params: { discussion: discussion_params }, format: :json

    expected_emails = [ @admin.email, users(:member_loud).email, users(:reader_quiet).email ]
    delivered_emails = ActionMailer::Base.deliveries.drop(deliveries_before).flat_map(&:to)
    assert_equal expected_emails.sort, delivered_emails.sort
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

  test "verified nonmember can start a closed group discussion from its template" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Ask the group for help')
    sign_in @alien

    assert_no_difference '@group.memberships.count' do
      post :create, params: { discussion: { title: 'A question for the group', group_id: @group.id, discussion_template_id: template.id } }
    end

    assert_response :success
    discussion = Discussion.find(JSON.parse(response.body).dig('discussions', 0, 'id'))
    reader = discussion.topic_readers.find_by!(user: @alien)
    assert_equal @group, discussion.group
    assert reader.guest?
    assert reader.admin?
    assert @alien.can?(:show, discussion)
    assert_not @alien.can?(:show, @discussion)
  end

  test "unverified nonmember cannot start a closed group discussion from a template" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    @alien.update!(email_verified: false)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Available')
    sign_in @alien

    post :create, params: { discussion: { title: 'Not permitted', group_id: @group.id, discussion_template_id: template.id } }

    assert_response :forbidden
  end

  test "nonmember can use tags prescribed by a closed group template but cannot add new tags" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Available', tags: [ 'Intake' ])
    sign_in @alien

    post :create, params: { discussion: { title: 'Tagged question', group_id: @group.id, discussion_template_id: template.id, tags: [ 'Intake' ] } }
    assert_response :success

    post :create, params: { discussion: { title: 'Injected tag', group_id: @group.id, discussion_template_id: template.id, tags: [ 'Intake', 'Not approved' ] } }
    assert_response :forbidden
  end

  test "nonmember cannot invite people while creating a group discussion" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Available')
    sign_in @alien

    recipient_params = [
      { recipient_emails: [ 'invitee@example.com' ] },
      { recipient_user_ids: [ @user.id ] },
      { recipient_audience: 'group' }
    ]

    recipient_params.each do |recipients|
      assert_no_difference [ 'Discussion.count', 'Topic.count', 'TopicReader.count' ] do
        post :create, params: {
          discussion: {
            title: 'Invitation attempt',
            group_id: @group.id,
            discussion_template_id: template.id,
            **recipients
          }
        }
      end
      assert_response :forbidden
    end
  end

  test "nonmember cannot start a closed group discussion without its kept template" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    other_template = DiscussionTemplate.create!(group: groups(:alien_group), author: @alien, process_name: 'Other group template', process_subtitle: 'Not valid for this group')
    discarded_template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Retired template', process_subtitle: 'No longer available', discarded_at: Time.current)
    sign_in @alien

    [ nil, other_template.id, discarded_template.id ].each do |template_id|
      assert_no_difference [ 'Discussion.count', 'Topic.count' ] do
        post :create, params: { discussion: { title: 'Not permitted', group_id: @group.id, discussion_template_id: template_id } }
      end
      assert_response :forbidden
    end
  end

  test "nonmember can start a public discussion from an open group template" do
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Group template', process_subtitle: 'Restricted by group privacy')
    sign_in @alien

    @group.update!(group_privacy: 'open', non_members_can_start_discussions: true)
    post :create, params: { discussion: { title: 'Public question', group_id: @group.id, discussion_template_id: template.id } }

    assert_response :success
    discussion = Discussion.find(JSON.parse(response.body).dig('discussions', 0, 'id'))
    assert_not discussion.private
    assert discussion.topic_readers.find_by!(user: @alien).guest?
  end

  test "nonmember cannot use the setting in a secret group" do
    @group.update!(group_privacy: 'secret', non_members_can_start_discussions: true)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Available')
    sign_in @alien

    post :create, params: { discussion: { title: 'Not permitted', group_id: @group.id, discussion_template_id: template.id } }

    assert_response :forbidden
  end

  test "nonmember cannot use the feature until it is enabled" do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: false)
    template = DiscussionTemplate.create!(group: @group, author: @admin, process_name: 'Guest intake', process_subtitle: 'Available')
    sign_in @alien

    post :create, params: { discussion: { title: 'Not permitted', group_id: @group.id, discussion_template_id: template.id } }

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

    assert_no_record_cache_fallbacks do
      get :show, params: { id: @discussion.key }
    end

    assert_response :success
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
