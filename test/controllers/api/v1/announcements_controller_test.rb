require 'test_helper'

class Api::V1::AnnouncementsControllerTest < ActionController::TestCase
  inline_jobs "history for topic includes users in response",
              "poll create as admin can add group member",
              "poll create as admin can add group member with notification",
              "anonymous poll create returns and notifies only newly added voters",
              "topic create as admin can add member",
              "topic create as admin can add multiple members",
              "outcome create member can add members when permission enabled",
              "group create with existing member notification",
              "group create invites to subgroup"
  setup do
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    sign_in @admin
  end

  # Count tests
  test "count returns a count of recipients" do
    hex = SecureRandom.hex(4)
    bill = User.create!(name: "bill#{hex}", email: "bill#{hex}@example.com", username: "bill#{hex}")
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    get :count, params: {
      recipient_emails_cmr: ["bill#{hex}@example.com", "new#{hex}@example.com"].join(','),
      recipient_user_xids: [bill.id].join('x'),
      recipient_audience: 'group',
      discussion_id: @discussion.id
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert json['count'] > 0
  end

  test "count is denied to a public-group non-member" do
    sign_in @alien

    get :count, params: { group_id: groups(:public_group).id }

    assert_response :forbidden
  end

  test "count requires sign in" do
    sign_out @admin

    get :count, params: { group_id: groups(:public_group).id }

    assert_response :unauthorized
  end

  test "count permits group members who cannot add members" do
    @group.update!(members_can_add_members: false)
    sign_in users(:user)

    get :count, params: { group_id: @group.id }

    assert_response :success
    assert_equal 0, JSON.parse(response.body)['count']
  end

  test "count permits an existing member email without guest permission" do
    @group.update!(members_can_add_guests: false, members_can_add_members: false)
    sign_in users(:user)

    get :count, params: {
      group_id: @group.id,
      recipient_emails_cmr: users(:member).email
    }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['count']
  end

  test "count denies a guest email without guest permission" do
    @group.update!(members_can_add_guests: false)
    sign_in users(:user)

    get :count, params: {
      group_id: @group.id,
      recipient_emails_cmr: 'guest@example.com'
    }

    assert_response :forbidden
  end

  test "count permits group audience when member can announce but cannot add members" do
    @group.update!(members_can_add_members: false, members_can_announce: true)
    sign_in users(:user)

    get :count, params: {
      group_id: @group.id,
      recipient_audience: 'group'
    }

    assert_response :success
    assert_operator JSON.parse(response.body)['count'], :>, 0
  end

  test "count denies group audience when member cannot announce" do
    @group.update!(members_can_add_members: true, members_can_announce: false)
    sign_in users(:user)

    get :count, params: {
      group_id: @group.id,
      recipient_audience: 'group'
    }

    assert_response :forbidden
  end

  test "count supports a new direct discussion without a target model" do
    get :count, params: {
      recipient_user_xids: users(:user).id
    }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['count']
  end

  test "count does not expose an unrelated user id" do
    get :count, params: {
      group_id: @group.id,
      recipient_user_xids: @alien.id
    }

    assert_response :success
    assert_equal 0, JSON.parse(response.body)['count']
  end

  test "direct discussion count does not expose an unrelated user id" do
    get :count, params: { recipient_user_xids: @alien.id }

    assert_response :success
    assert_equal 0, JSON.parse(response.body)['count']
  end

  test "search is denied to a public-group non-member" do
    sign_in @alien

    get :search, params: {group_id: groups(:public_group).id, q: @admin.username}

    assert_response :forbidden
  end

  test "search supports a new direct discussion without a target model" do
    get :search, params: { q: 'User' }

    assert_response :success
    user_ids = JSON.parse(response.body)['users'].map { |user| user['id'] }
    assert_includes user_ids, users(:user).id
    refute_includes user_ids, @alien.id
  end

  test "search requires sign in" do
    sign_out @admin

    get :search, params: { q: users(:user).username }

    assert_response :unauthorized
  end

  test "direct discussion search requires permission to create a direct discussion" do
    user = User.create!(
      email: "unverified-#{SecureRandom.hex(4)}@example.com",
      email_verified: false
    )
    sign_in user

    get :search, params: { q: users(:user).username }

    assert_response :forbidden
  end

  test "audience is denied to a public-group non-member" do
    sign_in @alien

    get :audience, params: {
      group_id: groups(:public_group).id,
      recipient_audience: 'group'
    }

    assert_response :forbidden
  end

  test "available audiences are denied to a public-group non-member" do
    sign_in @alien

    get :available_audiences, params: { group_id: groups(:public_group).id }

    assert_response :forbidden
  end

  test "available audiences require sign in" do
    sign_out @admin

    get :available_audiences, params: { group_id: groups(:public_group).id }

    assert_response :unauthorized
  end

  test "available audiences support a discussion topic without a poll" do
    get :available_audiences, params: { topic_id: @discussion.topic_id }

    assert_response :success
    audience_ids = JSON.parse(response.body).fetch("audiences").pluck("id")
    assert_includes audience_ids, "group-#{@group.id}"
    refute_includes audience_ids, "voters"
  end

  test "available audiences support a direct discussion" do
    discussion = DiscussionService.create(
      params: {
        title: "Direct discussion audiences",
        recipient_user_ids: [@alien.id]
      },
      actor: @admin
    )

    get :available_audiences, params: { discussion_id: discussion.id, include_actor: 1 }

    assert_response :success
    audiences = JSON.parse(response.body).fetch("audiences")
    audience_ids = audiences.pluck("id")
    topic_audience = audiences.find { |audience| audience["id"] == "topic" }

    assert_includes audience_ids, "topic"
    assert_equal "topic", topic_audience.fetch("kind")
    refute audience_ids.any? { |id| id.start_with?("group-") }
  end

  test "available audiences for a subgroup include parent members who are not already in the subgroup" do
    subgroup = groups(:subgroup)

    get :available_audiences, params: { group_id: subgroup.id, exclude_members: 1 }

    assert_response :success
    audiences = JSON.parse(response.body).fetch("audiences")
    parent_audience = audiences.find { |audience| audience["id"] == "group-#{@group.id}" }

    assert_equal @group.name, parent_audience.fetch("name")
    assert_equal 1, parent_audience.fetch("size")
    refute audiences.any? { |audience| audience["id"] == "group-#{subgroup.id}" }

    get :audience, params: {
      group_id: subgroup.id,
      recipient_audience: "group-#{@group.id}",
      exclude_members: 1
    }

    assert_response :success
    assert_equal [ users(:member).id ], JSON.parse(response.body).fetch("users").pluck("id")
  end

  test "available audiences for a parent group include members of its subgroups" do
    subgroup = groups(:subgroup)

    get :available_audiences, params: { group_id: @group.id, exclude_members: 1 }

    assert_response :success
    audiences = JSON.parse(response.body).fetch("audiences")
    subgroup_audience = audiences.find { |audience| audience["id"] == "group-#{subgroup.id}" }

    assert_equal subgroup.name, subgroup_audience.fetch("name")
    assert_equal 1, subgroup_audience.fetch("size")
    refute audiences.any? { |audience| audience["id"] == "group-#{@group.id}" }
  end

  test "group audiences do not expose a related group whose members the actor cannot browse" do
    hex = SecureRandom.hex(4)
    sibling = Group.create!(
      name: "Private sibling #{hex}",
      parent: @group,
      handle: "testgroup-private-sibling-#{hex}",
      group_privacy: "secret"
    )
    sibling.add_member!(@alien)

    get :available_audiences, params: { group_id: groups(:subgroup).id, exclude_members: 1 }

    assert_response :success
    audience_ids = JSON.parse(response.body).fetch("audiences").pluck("id")
    refute_includes audience_ids, "group-#{sibling.id}"

    get :audience, params: {
      group_id: groups(:subgroup).id,
      recipient_audience: "group-#{sibling.id}",
      exclude_members: 1
    }

    assert_response :forbidden
  end

  test "group audiences cannot resolve a group from another organization" do
    get :audience, params: {
      group_id: groups(:subgroup).id,
      recipient_audience: "group-#{groups(:alien_group).id}",
      exclude_members: 1
    }

    assert_response :not_found
  end

  test "group audiences cannot resolve the destination group" do
    subgroup = groups(:subgroup)

    get :audience, params: {
      group_id: subgroup.id,
      recipient_audience: "group-#{subgroup.id}",
      exclude_members: 1
    }

    assert_response :not_found
  end

  test "count ignores obsolete recipient usernames" do
    get :count, params: {
      group_id: @group.id,
      recipient_usernames: @alien.username
    }

    assert_response :success
    assert_equal 0, JSON.parse(response.body)['count']
  end

  # History tests
  test "history responds with topic_item history" do
    get :history, params: { group_id: @group.id }
    assert_response :success
  end

  test "history for topic includes users in response" do
    member = users(:user)
    topic = @discussion.topic
    TopicService.invite(
      topic: topic,
      actor: @admin,
      params: { recipient_user_ids: [ member.id ] }
    )

    get :history, params: { topic_id: topic.id }

    assert_response :success
    json = JSON.parse(response.body)
    assert json['data'].any?
    assert json['users'].any?
    assert_includes json['users'].map { |u| u['id'] }, member.id
  end

  test "history for topic denied to non-members" do
    sign_in @alien

    get :history, params: { topic_id: @discussion.topic.id }

    assert_response :forbidden
  end

  test "history for public topic denied to non-members" do
    sign_in @alien

    get :history, params: { topic_id: topics(:public_discussion_topic).id }

    assert_response :forbidden
  end

  test "history for public group denied to non-members" do
    sign_in @alien

    get :history, params: { group_id: groups(:public_group).id }

    assert_response :forbidden
  end

  test "history for public group requires sign in" do
    sign_out @admin

    get :history, params: { group_id: groups(:public_group).id }

    assert_response :unauthorized
  end

  test "history for topic includes user_mentioned notifications" do
    member = users(:user)
    topic = @discussion.topic
    parent_topic_item = TopicItem.find_by(kind: 'new_discussion', topic: @discussion.topic)
    comment = Comment.create!(body: "hello", parent: parent_topic_item, user: @admin)
    comment.create_missing_created_topic_item!
    notification = Notification.create!(
      kind: "user_mentioned",
      subject: comment,
      actor: @admin
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: member,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    get :history, params: { topic_id: topic.id }

    assert_response :success
    json = JSON.parse(response.body)
    mention_notification = json['data'].find { |e| e['kind'] == 'user_mentioned' }
    assert mention_notification, "expected user_mentioned notification in history"
    assert_includes mention_notification['notifications'].map { |n| n['user_id'] }, member.id
  end

  test "history includes eventless poll announcements" do
    member = users(:user)
    poll = create_test_poll
    notification = NotificationService.create!(
      kind: "poll_announced",
      subject: poll,
      actor: @admin,
      recipient_user_ids: [ member.id ]
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    get :history, params: { poll_id: poll.id }

    assert_response :success
    entry = JSON.parse(response.body)["data"].find { |item| item["id"] == "notification_#{notification.id}" }
    assert entry
    assert_equal "poll_announced", entry["kind"]
    assert_equal [ member.id ], entry["notifications"].map { |state| state["user_id"] }
  end

  test "anonymous poll history hides viewed state for eventless announcements" do
    member = users(:user)
    poll = create_test_poll(anonymous: true)
    notification = NotificationService.create!(
      kind: "poll_announced",
      subject: poll,
      actor: @admin,
      recipient_user_ids: [ member.id ]
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    notification.notification_deliveries.find_by!(channel: "in_app", recipient: member)
                .update!(viewed_at: Time.current)

    get :history, params: { poll_id: poll.id }

    body = JSON.parse(response.body)
    entry = body["data"].find { |item| item["id"] == "notification_#{notification.id}" }
    assert_response :success
    assert_equal false, body["allow_viewed"]
    assert_equal false, entry["notifications"].first["viewed"]
  end

  test "anonymous poll history and counts do not expose closing-reminder recipients" do
    member = users(:user)
    poll = create_test_poll(anonymous: true)
    notification = NotificationService.create!(
      kind: "poll_closing_soon",
      subject: poll,
      actor: @admin
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: member,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    get :history, params: { poll_id: poll.id }
    assert_response :success
    assert_empty JSON.parse(response.body)["data"]

    get :users_notified_count, params: { poll_id: poll.id }
    assert_response :success
    assert_equal 0, JSON.parse(response.body)["count"]
  end

  test "search existing only filters target members" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "Existing #{hex}", email: "existing#{hex}@example.com", username: "existing#{hex}")
    non_member = User.create!(name: "Existing Outsider #{hex}", email: "outsider#{hex}@example.com", username: "outsider#{hex}")
    @group.add_member!(member)

    get :search, params: { group_id: @group.id, q: "Existing", existing_only: 1 }

    assert_response :success
    user_ids = JSON.parse(response.body)['users'].map { |user| user['id'] }
    assert_includes user_ids, member.id
    refute_includes user_ids, non_member.id
  end

  # -- Poll announcement tests --

  def create_test_poll(**extra)
    PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: @group.id,
      specified_voters_only: true,
      poll_option_names: %w[agree disagree],
      closing_at: 5.days.from_now
    }.merge(extra), actor: @admin)
  end

  test "audience voters works for anonymous polls" do
    poll = create_test_poll(anonymous: true, specified_voters_only: false)
    get :audience, params: {poll_id: poll.id, recipient_audience: 'voters'}
    assert_response :success
  end


  test "audience voters still works for non-anonymous polls" do
    poll = create_test_poll(specified_voters_only: false)
    get :audience, params: { poll_id: poll.id, recipient_audience: 'voters' }
    assert_response :success
  end

  test "poll create can add group members when members_can_add_guests=false" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['stances'][0]['participant_id']
  end

  test "count supports topic audience for polls" do
    poll = create_test_poll

    get :count, params: {
      poll_id: poll.id,
      recipient_audience: 'topic',
      include_actor: '1'
    }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['count']
  end

  test "poll create with topic audience requires group notification permission" do
    poll = create_test_poll
    @group.update!(members_can_announce: false)
    Membership.find_by!(user_id: @admin.id, group_id: @group.id).update!(admin: false)

    post :create, params: {
      poll_id: poll.id,
      recipient_audience: 'topic',
      include_actor: '1'
    }

    assert_response :forbidden
  end

  test "poll create with topic audience permits a group member who can notify the group" do
    poll = create_test_poll
    @group.update!(members_can_announce: true)
    sign_in users(:user)

    post :create, params: {
      poll_id: poll.id,
      recipient_audience: 'topic',
      include_actor: '1'
    }

    assert_response :success
  end

  test "poll create supports topic audience" do
    poll = create_test_poll

    post :create, params: {
      poll_id: poll.id,
      recipient_audience: 'topic',
      include_actor: '1'
    }

    assert_response :success
    assert_includes JSON.parse(response.body)['stances'].map { |stance| stance['participant_id'] }, @admin.id
  end

  test "poll create cannot invite guests when members_can_add_guests=false" do
    poll = create_test_poll

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "poll create can invite guests when members_can_add_guests=true" do
    poll = create_test_poll

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
  end

  test "anonymous poll create returns and notifies only newly added voters" do
    poll = create_test_poll(anonymous: true)
    existing_voter = users(:user)
    new_voter = @group.members.humans.where.not(id: [ @admin.id, existing_voter.id ]).first!
    PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_user_ids: [ existing_voter.id ] }
    )
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
      ),
      actor: existing_voter
    )

    post :create, params: {
      poll_id: poll.id,
      recipient_user_ids: [ existing_voter.id, new_voter.id ],
      notify_recipients: true
    }

    assert_response :success
    assert_equal [ new_voter.id ], JSON.parse(response.body).fetch("users").pluck("id")
    assert_equal 1, poll.anonymous_poll_voters.where(voter_id: existing_voter.id).count
    assert_equal 1, poll.anonymous_poll_voters.where(voter_id: new_voter.id).count

    notification = Notification.about(poll).where(kind: "poll_announced").order(:id).last!
    assert_equal [ new_voter.id ], notification.recipient_user_ids
    assert_equal [ new_voter.id ], notification.notification_deliveries
                                                  .where(channel: "in_app")
                                                  .pluck(:recipient_id)
    assert_not notification.notification_deliveries.exists?(recipient: existing_voter)
  end

  test "poll create can invite a voter after an anonymous ballot is submitted" do
    poll = create_test_poll(anonymous: true)
    voter = users(:user)
    PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_user_ids: [voter.id] }
    )
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
      ),
      actor: voter
    )

    post :create, params: { poll_id: poll.id, recipient_emails: ['late-voter@example.com'] }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['users'].length
    assert poll.anonymous_poll_voters.joins(:voter).exists?(users: { email: 'late-voter@example.com' })
    assert_equal 1, poll.reload.undecided_voters_count
  end

  test "poll create reports the invitation rate limit" do
    poll = create_test_poll
    error = ThrottleService::LimitReached.new('Throttled')
    trial_limit = ENV['TRIAL_INVITATIONS_RATE_LIMIT']
    paid_limit = ENV['PAID_INVITATIONS_RATE_LIMIT']
    ENV['TRIAL_INVITATIONS_RATE_LIMIT'] = '500'
    ENV['PAID_INVITATIONS_RATE_LIMIT'] = '50000'

    ThrottleService.stub(:limit!, ->(**) { raise error }) do
      post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    end

    assert_response :too_many_requests
    assert_equal I18n.t('errors.invitation_rate_limit_reached_contact_support'), JSON.parse(response.body).dig('flash', 'error')
  ensure
    if trial_limit.nil?
      ENV.delete('TRIAL_INVITATIONS_RATE_LIMIT')
    else
      ENV['TRIAL_INVITATIONS_RATE_LIMIT'] = trial_limit
    end
    if paid_limit.nil?
      ENV.delete('PAID_INVITATIONS_RATE_LIMIT')
    else
      ENV['PAID_INVITATIONS_RATE_LIMIT'] = paid_limit
    end
  end

  test "poll create member cannot announce when members_can_announce=false" do
    poll = create_test_poll

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "poll create member can notify voters when members_can_announce=false" do
    poll = create_test_poll(specified_voters_only: false)

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'voters' }
    assert_response :success
  end

  test "poll create member can announce when members_can_announce=true" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group', recipient_user_ids: [@admin.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @group.members.count, json['stances'].length
  end

  test "poll create as admin can add group member" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: true)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id], notify_recipients: true }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal member.id, json['stances'][0]['participant_id']
    assert_equal 1, NotificationDelivery.joins(:notification).where(
      recipient: member,
      channel: "in_app",
      notifications: { kind: "poll_announced" }
    ).count
    assert_includes poll.voters, member
  end

  test "poll create as admin can add group member with notification" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_announce: false, members_can_add_guests: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id], notify_recipients: true }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal 1, NotificationDelivery.joins(:notification).where(
      recipient: member,
      channel: "in_app",
      notifications: { kind: "poll_announced" }
    ).count
  end

  # -- Topic announcement tests --

  test "topic create members can add guests when permission enabled" do
    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { topic_id: @discussion.topic_id, recipient_emails: ['jim@example.com'] }
    assert_response :success
  end

  test "topic create members cannot add guests when permission disabled" do
    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { topic_id: @discussion.topic_id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "topic create explains when subscription does not allow guests" do
    Subscription.for(@group).update!(allow_guests: false)

    post :create, params: { topic_id: @discussion.topic_id, recipient_emails: ['jim@example.com'] }

    assert_response :forbidden
    assert_equal I18n.t("unauthorized.add_guests.all"), JSON.parse(response.body)["error"]
  end

  test "topic create members can announce when permission enabled" do
    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { topic_id: @discussion.topic_id, recipient_audience: 'group' }
    assert_response :success
  end

  test "topic create members cannot announce when permission disabled" do
    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { topic_id: @discussion.topic_id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "topic create as admin can add member" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: true)

    post :create, params: { topic_id: @discussion.topic_id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['topic_readers'][0]['user_id']
    notification = Notification.where(kind: "discussion_announced").order(:id).last
    assert_equal "TopicItem", notification.subject_type
    assert_equal @discussion.created_topic_item.id, notification.subject_id
    assert_equal 1, NotificationDelivery.where(
      recipient: member,
      channel: "in_app",
      notification: notification
    ).count
    assert_includes @discussion.readers, member
  end

  test "topic create as admin cannot add non_member" do
    hex = SecureRandom.hex(4)
    non_member = User.create!(name: "non#{hex}", email: "non#{hex}@example.com", username: "non#{hex}")

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: true)

    post :create, params: { topic_id: @discussion.topic_id, recipient_user_ids: [non_member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 0, json['topic_readers'].length
  end

  test "topic create as admin can add multiple members" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: true)

    post :create, params: { topic_id: @discussion.topic_id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['topic_readers'][0]['user_id']
    assert_equal 1, NotificationDelivery.where(
      recipient: member,
      channel: "in_app",
      notification: Notification.where(kind: "discussion_announced")
    ).count
    assert_includes @discussion.readers, member
  end

  # -- Outcome announcement tests --

  def create_closed_poll_with_outcome
    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)
    PollService.close(poll: poll, actor: @admin)
    outcome = Outcome.new(poll: poll, author: @admin, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @admin)
    [poll, outcome]
  end

  def create_closed_anonymous_poll_with_outcome
    hex = SecureRandom.hex(4)
    voter = User.create!(name: "Anonymous voter #{hex}", email: "anonymous-voter-#{hex}@example.com", username: "anonymousvoter#{hex}")
    non_voter = User.create!(name: "Anonymous non-voter #{hex}", email: "anonymous-non-voter-#{hex}@example.com", username: "anonymousnonvoter#{hex}")
    @group.add_member!(voter)
    @group.add_member!(non_voter)

    poll = PollService.create(params: {
      title: "Anonymous test poll",
      poll_type: "proposal",
      group_id: @group.id,
      anonymous: true,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)
    poll.anonymous_poll_voters.find_by!(voter: voter).update!(ballot_submitted: true)
    poll.update_counts!
    PollService.close(poll: poll, actor: @admin)

    outcome = Outcome.new(poll: poll, author: @admin, statement: "Anonymous test outcome")
    OutcomeService.create(outcome: outcome, actor: @admin)
    [poll, outcome, voter, non_voter]
  end

  test "available audiences for detached anonymous outcomes exclude voter status audiences" do
    _poll, outcome, _voter, _non_voter = create_closed_anonymous_poll_with_outcome

    get :available_audiences, params: { outcome_id: outcome.id }

    assert_response :success
    audience_ids = JSON.parse(response.body).fetch("audiences").pluck("id")
    assert_includes audience_ids, "voters"
    refute_includes audience_ids, "decided_voters"
    refute_includes audience_ids, "undecided_voters"
    refute_includes audience_ids, "non_voters"
  end

  test "available audiences for identified outcomes include voter status audiences" do
    hex = SecureRandom.hex(4)
    voter = User.create!(name: "Identified voter #{hex}", email: "identified-voter-#{hex}@example.com", username: "identifiedvoter#{hex}")
    non_voter = User.create!(name: "Identified non-voter #{hex}", email: "identified-non-voter-#{hex}@example.com", username: "identifiednonvoter#{hex}")
    @group.add_member!(voter)
    @group.add_member!(non_voter)

    poll = PollService.create(params: {
      title: "Identified test poll",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)
    poll.stances.latest.find_by!(participant: voter).update!(choice: poll.poll_option_names.first, cast_at: Time.current)
    poll.update_counts!
    PollService.close(poll: poll, actor: @admin)
    outcome = Outcome.new(poll: poll, author: @admin, statement: "Identified test outcome")
    OutcomeService.create(outcome: outcome, actor: @admin)

    get :available_audiences, params: { outcome_id: outcome.id }

    assert_response :success
    audience_ids = JSON.parse(response.body).fetch("audiences").pluck("id")
    assert_includes audience_ids, "voters"
    assert_includes audience_ids, "decided_voters"
    assert_includes audience_ids, "undecided_voters"
  end

  test "detached anonymous outcome audience cannot expand voters by participation status" do
    _poll, outcome, _voter, _non_voter = create_closed_anonymous_poll_with_outcome

    get :audience, params: { outcome_id: outcome.id, recipient_audience: "decided_voters" }

    assert_response :forbidden
  end

  test "detached anonymous outcome audience cannot expand non-voters" do
    _poll, outcome, _voter, _non_voter = create_closed_anonymous_poll_with_outcome

    get :audience, params: { outcome_id: outcome.id, recipient_audience: "non_voters" }

    assert_response :forbidden
  end

  test "detached anonymous outcome audience count rejects participation status" do
    _poll, outcome, _voter, _non_voter = create_closed_anonymous_poll_with_outcome

    get :count, params: { outcome_id: outcome.id, recipient_audience: "undecided_voters" }

    assert_response :forbidden
  end

  test "detached anonymous outcome notification rejects participation status" do
    _poll, outcome, voter, _non_voter = create_closed_anonymous_poll_with_outcome
    voter.notifications.destroy_all

    post :create, params: { outcome_id: outcome.id, recipient_audience: "decided_voters" }

    assert_response :forbidden
    assert_empty voter.notifications
  end

  test "outcome create does not permit stranger to announce" do
    _poll, outcome = create_closed_poll_with_outcome

    hex = SecureRandom.hex(4)
    stranger = User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}")
    sign_in stranger

    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :forbidden
  end

  test "outcome create member can add members when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    member.notifications.destroy_all

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, NotificationDelivery.joins(:notification).where(
      recipient: member,
      channel: "in_app",
      notifications: { kind: "outcome_announced" }
    ).count
  end

  test "outcome create member cannot add guests when permission disabled" do
    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "outcome create member can notify group when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :success
  end

  test "outcome create member cannot notify group when permission disabled" do
    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @admin.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "outcome create with member notification" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success
  end

  # -- Group announcement tests --

  test "group create allows adding members when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member, inviter: @admin)
    @group.update(members_can_add_members: true)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ["jim#{hex}@example.com"] }
    assert_response :success
  end

  test "group create disallows adding members when permission disabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member, inviter: @admin)
    @group.update(members_can_add_members: false)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ["jim#{hex}@example.com"] }
    assert_response :forbidden
  end

  test "group create cannot add existing user by id if no groups in common" do
    hex = SecureRandom.hex(4)
    alien = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}")

    post :create, params: { group_id: @group.id, recipient_user_ids: [alien.id] }
    assert_response :success

    assert_equal 0, alien.notifications.count
    assert_equal 0, alien.memberships.count
  end

  test "group create with existing member notification" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    post :create, params: { group_id: @group.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, NotificationDelivery.joins(:notification).where(
      recipient: member,
      channel: "in_app",
      notifications: { kind: "membership_created" }
    ).count
    assert_includes @group.members, member
  end

  test "group create invite with multiple groups" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    subgroup = Group.create!(name: "Test Sub #{hex}", parent: @group, handle: "testgroup-sub#{hex}")
    subgroup2 = Group.create!(name: "Test Sub2 #{hex}", parent: @group, handle: "testgroup-sub2#{hex}")

    @group.add_member!(member, inviter: @admin)
    subgroup.add_admin!(@admin)
    subgroup2.add_admin!(@admin)

    post :create, params: {
      group_id: @group.id,
      recipient_user_ids: [member.id],
      invited_group_ids: [subgroup.id, subgroup2.id]
    }

    assert_response :success
    assert_includes @group.members, member
  end

  test "group create does not invite users with no group in common" do
    hex = SecureRandom.hex(4)
    alien = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}")

    post :create, params: {
      group_id: @group.id,
      recipient_user_ids: [alien.id],
      invited_group_ids: [@group.id]
    }

    assert_response :success
    assert_equal 0, alien.notifications.count
    assert_equal 0, alien.memberships.pending.count
  end

  test "group create invites to subgroup" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    subgroup = Group.create!(name: "Test Sub #{hex}", parent: @group, handle: "testgroup-sub#{hex}")

    @group.add_member!(member)
    subgroup.add_admin!(@admin)
    subgroup.add_member!(member)

    post :create, params: { group_id: subgroup.id, recipient_user_ids: [member.id] }

    assert_response :success
    member.reload

    assert_equal 1, NotificationDelivery.joins(:notification).where(
      recipient: member,
      channel: "in_app",
      notifications: { kind: "membership_created" }
    ).count
  end
end
