require 'test_helper'

class PollServiceTest < ActiveSupport::TestCase
  inline_jobs "expires a lapsed poll",
              "open_scheduled_polls delivers emails to voters when notify_on_open is true",
              "poll topic item sends loud subscriber email without a notification row"
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
  end

  # -- create_stances --
  # Note: Use specified_voters_only polls so auto-creation doesn't preempt create_stances

  test "creates stance by user id" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stancemember")
    @group.add_member!(member)

    assert_equal 0, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by email" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceemail")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by audience" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceaudience")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, audience: 'group')
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "only creates stances once per user" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceonce")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    count = Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    assert_equal 1, count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stances for specified voters" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("voldefault")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert Stance.where(participant_id: member.id, poll: poll).exists?
  end

  test "notified invitation rolls back its stance when notification creation fails" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("atomicpollinvite")
    @group.add_member!(member)

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        PollService.invite(
          poll: poll,
          actor: @user,
          params: { recipient_user_ids: [ member.id ], notify_recipients: true }
        )
      end
    end

    assert_not Stance.exists?(poll: poll, participant: member)
  end

  # -- create --

  test "creates a new poll" do
    poll = nil
    assert_difference 'Poll.count', 1 do
      poll = PollService.create(params: poll_params, actor: @user)
    end

    reader = TopicReader.for(user: @user, topic: poll.topic)
    assert reader.reload.has_read?(poll.created_topic_item.sequence_id)
    assert_equal 0, reader.unread_items_count
    assert_not Notification.exists?(kind: "poll_created", subject: poll)
  end

  test "poll topic item sends loud subscriber email without a notification row" do
    subscriber = users(:member)
    poll = PollService.create(params: poll_params, actor: @user)
    TopicReader.for(user: subscriber, topic: poll.topic).set_volume!(:loud)
    ActionMailer::Base.deliveries.clear
    TopicItems::PollCreated.find(poll.created_topic_item.id).send_subscriber_emails!

    assert_includes ActionMailer::Base.deliveries.flat_map(&:to), subscriber.email
    assert_not Notification.exists?(kind: "poll_created", subject: poll)
  end

  test "anonymous poll creation does not use voter records as poll-created recipients" do
    voter = users(:member)
    poll = PollService.create(
      params: poll_params(
        anonymous: true,
        specified_voters_only: true,
        recipient_user_ids: [ voter.id ],
        notify_on_open: false
      ),
      actor: @user
    )
    assert poll.detached_anonymous?
    assert poll.anonymous_poll_voters.exists?(voter: voter)
    assert_not Stance.exists?(poll: poll, participant: voter)
    assert_not Notification.exists?(kind: "poll_created", subject: poll)
  end

  test "anonymous poll creation does not depend on notification creation" do
    voter = users(:member)

    poll = nil
    NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
      poll = PollService.create(
        params: poll_params(
          anonymous: true,
          specified_voters_only: true,
          recipient_user_ids: [ voter.id ],
          notify_on_open: false
        ),
        actor: @user
      )
    end

    assert_predicate poll, :persisted?
    assert poll.anonymous_poll_voters.exists?(voter: voter)
    assert poll.created_topic_item
  end

  test "populates custom poll options" do
    poll = PollService.create(params: poll_params(
      poll_type: "poll",
      poll_option_names: ["green"]
    ), actor: @user)
    assert_equal 1, poll.reload.poll_options.count
    assert_equal "green", poll.poll_options.first.name
  end

  test "does not create an invalid poll" do
    assert_no_difference 'Poll.count' do
      assert_raises ActiveRecord::RecordInvalid do
        PollService.create(params: poll_params(title: ""), actor: @user)
      end
    end
  end

  test "does not allow unauthorized users to create polls" do
    outsider = create_unique_user("pollunauthorized")
    assert_raises CanCan::AccessDenied do
      PollService.create(params: poll_params, actor: outsider)
    end
  end

  test "poll_created creates poll_announced notification when notify_on_open is true" do
    poll = PollService.create(params: poll_params(notify_on_open: true), actor: @user)
    assert poll.opened?
    assert Notification.where(kind: "poll_announced", subject: poll).exists?
  end

  test "poll_created does not publish poll_announced when notify_on_open is false" do
    poll = PollService.create(params: poll_params(notify_on_open: false), actor: @user)
    assert poll.opened?
    refute Notification.where(kind: "poll_announced", subject: poll).exists?
  end

  test "publish_topic_if_active excludes group records from topic broadcasts" do
    poll = create_poll
    calls = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { calls << [models, options] }) do
      PollService.publish_topic_if_active(poll)
    end

    cache = RecordCache.for_collection([poll.topic], nil, ['group'])

    assert_not_empty calls
    assert calls.all? { |models, _options| models == [poll.topic] }
    assert calls.all? { |_models, options| options[:scope] == {exclude_types: ['group']} }
    assert_nil cache.scope[:groups_by_id]
    assert_nil cache.scope[:subscriptions_by_group_id]
  end

  # Note: poll mention notification test omitted due to asset pipeline dependency
  # (poll_mailer/vote-button-.png). Mention notifications are covered in discussion_service_test.

  # -- update --

  test "updates an existing poll" do
    poll = create_poll
    PollService.update(poll: poll, params: { details: "A new description" }, actor: @user)
    assert_equal "A new description", poll.reload.details
  end

  test "updating a poll preserves its discussion topic tags" do
    discussion = discussions(:discussion)
    discussion.topic.update!(tags: [ 'literature' ])
    poll = PollService.build(params: poll_params(topic_id: discussion.topic_id), actor: @user)
    poll.save!

    TopicItems::PollEdited.stub(:publish!, nil) do
      PollService.update(
        poll: poll,
        params: { details: 'Updated poll details', tags: [] },
        actor: @admin
      )
    end

    assert_equal [ 'literature' ], discussion.topic.reload.tags
  end

  test "does not transfer poll topic group on update" do
    poll = create_poll
    original_group_id = poll.topic.group_id
    other_group = Group.create!(
      name: "Other Poll Group",
      handle: "otherpollgroup-#{SecureRandom.hex(4)}"
    )
    other_group.add_admin!(@user)

    PollService.update(poll: poll, params: { group_id: other_group.id }, actor: @user)

    assert_equal original_group_id, poll.reload.topic.group_id
  end

  test "does not allow unauthorized users to update polls" do
    poll = create_poll
    outsider = create_unique_user("pollupdate")
    assert_raises CanCan::AccessDenied do
      PollService.update(poll: poll, params: { details: "Hacked" }, actor: outsider)
    end
    assert_not_equal "Hacked", poll.reload.details
  end

  test "does not save an invalid poll on update" do
    poll = create_poll
    old_title = poll.title
    PollService.update(poll: poll, params: { title: "" }, actor: @user)
    assert_equal old_title, poll.reload.title
  end

  test "does not create a poll edited topic_item for a title change without a message" do
    poll = create_poll
    assert_no_difference "TopicItems::PollEdited.where(kind: :poll_edited).count" do
      PollService.update(poll: poll, params: { title: "BIG CHANGES!" }, actor: @user)
    end
  end

  test "does not create a poll edited topic_item for option changes without a message" do
    poll = create_poll
    assert_no_difference "TopicItems::PollEdited.where(kind: :poll_edited).count" do
      PollService.update(poll: poll, params: { poll_option_names: ["new_option"] }, actor: @user)
    end
  end

  test "poll edit keeps its history topic_item and creates one logical notification" do
    poll = create_poll
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: poll.topic).set_volume!(:normal)

    topic_item = PollService.update(
      poll: poll,
      params: {
        title: "Notification-backed poll edit",
        recipient_user_ids: [ recipient.id ],
        recipient_message: "Please review the poll changes"
      },
      actor: @user
    )
    notification = Notification.find_by!(kind: "poll_edited", subject: poll)

    assert_equal "poll_edited", topic_item.kind
    assert_equal poll.topic_id, topic_item.topic_id
    assert_not_respond_to topic_item, :recipient_message
    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal "Please review the poll changes", notification.recipient_message
    assert_equal 1, Notification.where(kind: "poll_edited", subject: poll).count

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "poll edit separates a newly mentioned recipient from edit email delivery" do
    poll = create_poll
    recipient = users(:member)
    recipient.update!(username: "pollmention#{SecureRandom.hex(4)}")
    TopicReader.for(user: recipient, topic: poll.topic).set_volume!(:normal)

    PollService.update(
      poll: poll,
      params: {
        details: "Please review this, @#{recipient.username}",
        details_format: "md",
        recipient_user_ids: [ recipient.id ]
      },
      actor: @user
    )
    notification = Notification.find_by!(kind: "poll_edited", subject: poll)

    assert_equal [ recipient.id ], notification.audience_values["newly_mentioned_user_ids"]
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
    assert Notification.exists?(kind: "user_mentioned", subject: poll)
  end

  test "eventless poll edit without a direct audience does not create a notification" do
    poll = create_poll

    assert_no_difference "TopicItem.where(kind: 'poll_edited').count" do
      NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
        PollService.update(
          poll: poll,
          params: { title: "Saved without a notification" },
          actor: @user
        )
      end
    end

    assert_equal "Saved without a notification", poll.reload.title
  end

  # -- close --

  test "closes a poll" do
    poll = create_poll
    topic_item = PollService.close(poll: poll, actor: @user)
    assert_not_nil poll.reload.closed_at
    assert_equal poll.topic_id, topic_item.topic_id
    assert_not Notification.exists?(kind: "poll_closed_by_user", subject: poll)
  end

  test "poll close resolves subscribed chatbot delivery without a per-user notification" do
    poll = create_poll
    chatbot = nil
    SafeHttpService.stub(:safe_to_fetch?, true) do
      chatbot = Chatbot.create!(
        group: @group,
        author: @user,
        name: "Poll close chatbot",
        server: "https://poll-close.example.test/hook",
        webhook_kind: "markdown",
        kind: "webhook",
        event_kinds: [ "poll_closed_by_user" ]
      )
    end

    stub_request(:post, chatbot.server).to_return(status: 200)
    topic_item = PollService.close(poll: poll, actor: @user)
    Resolv.stub(:getaddresses, [ "93.184.216.34" ]) do
      PublishChatbotTopicItemWorker.perform_now(topic_item.id)
    end

    assert_requested :post, chatbot.server, times: 1
    assert_not Notification.exists?(kind: "poll_closed_by_user", subject: poll)
  end

  test "poll close does not depend on notification creation" do
    poll = create_poll

    topic_item = nil
    NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
      topic_item = PollService.close(poll: poll, actor: @user)
    end

    assert_not_nil poll.reload.closed_at
    assert_equal topic_item.id, TopicItem.find_by!(kind: "poll_closed_by_user", itemable: poll).id
  end

  test "does not allow change from anonymous to normal" do
    poll = create_poll(anonymous: true)
    poll.anonymous = false
    assert_not poll.save
  end

  test "does not allow hiding results change after creation" do
    poll = create_poll
    poll.update!(hide_results: :until_closed)
    poll.hide_results = :off
    assert_not poll.save
  end

  test "disallows new stances after close" do
    poll = create_poll
    stance = Stance.new(poll: poll)
    assert @user.ability.can?(:create, stance)
    PollService.close(poll: poll, actor: @user)
    assert_not @user.ability.can?(:create, stance)
  end

  # -- expire_lapsed_polls --

  test "expires a lapsed poll" do
    poll = create_poll
    poll.update_attribute(:closing_at, 1.day.ago)
    PollService.expire_lapsed_polls
    assert_not_nil poll.reload.closed_at
  end

  test "does not expire active poll" do
    poll = create_poll
    PollService.expire_lapsed_polls
    assert_nil poll.reload.closed_at
  end

  test "does not touch already closed polls" do
    poll = create_poll
    poll.update!(closing_at: 1.day.ago, closed_at: 1.day.ago)
    original_closed_at = poll.reload.closed_at
    PollService.expire_lapsed_polls
    assert_equal original_closed_at, poll.reload.closed_at
  end

  # -- scheduled opening (opening_at) --

  test "scheduled poll is not opened at create time" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?, "poll should not be opened when opening_at is in the future"
    refute Notification.where(kind: "poll_announced", subject: poll).exists?,
      "no poll_announced notification should be created for scheduled poll at create time"
  end

  test "open_scheduled_polls opens scheduled polls and sends poll_announced when notify_on_open is true" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?

    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    assert Notification.where(kind: "poll_announced", subject: poll).exists?,
      "poll_announced notification should be created when notify_on_open is true"
  end

  test "open_scheduled_polls opens scheduled polls without poll_announced when notify_on_open is false" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    ), actor: @user)
    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    refute Notification.where(kind: "poll_announced", subject: poll).exists?,
      "no poll_announced topic_item when notify_on_open is false"
  end

  test "open_scheduled_polls does not open polls whose opening_at is still in the future" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    PollService.open_scheduled_polls
    poll.reload
    refute poll.opened?, "poll should not be opened when opening_at is still in the future"
  end

  # -- reopen --

  test "reopen sends poll_announced when notify_on_open is true" do
    poll = create_poll(notify_on_open: true)
    PollService.close(poll: poll, actor: @user)
    poll.reload

    announced_count_before = Notification.where(kind: "poll_announced", subject: poll).count
    PollService.reopen(poll: poll, params: { closing_at: 7.days.from_now }, actor: @user)
    poll.reload

    assert poll.opened?, "poll should be opened after reopen"
    assert_nil poll.opening_at, "opening_at should be nil after reopen"
    assert_operator Notification.where(kind: "poll_announced", subject: poll).count, :>, announced_count_before,
      "poll_announced notification should be created on reopen with notify_on_open=true"
  end

  test "reopen does not send poll_announced when notify_on_open is false" do
    poll = create_poll(notify_on_open: false)
    PollService.close(poll: poll, actor: @user)
    poll.reload

    announced_count_before = Notification.where(kind: "poll_announced", subject: poll).count
    PollService.reopen(poll: poll, params: { closing_at: 7.days.from_now }, actor: @user)
    poll.reload

    assert poll.opened?, "poll should be opened after reopen"
    assert_equal announced_count_before, Notification.where(kind: "poll_announced", subject: poll).count,
      "no poll_announced topic_item on reopen when notify_on_open is false"
  end

  # -- invite to scheduled poll --

  test "invite to scheduled poll creates stances but does not send poll_announced" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      specified_voters_only: true,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?

    member = create_unique_user("scheduledinvite")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    PollService.invite(poll: poll, actor: @user, params: {
      recipient_user_ids: [member.id],
      notify_recipients: false
    })

    assert Stance.where(participant_id: member.id, poll: poll).exists?,
      "stance should be created for invited user"
    refute Notification.where(kind: "poll_announced", subject: poll).exists?,
      "no poll_announced when inviting to scheduled poll without notify_recipients"
  end

  # -- email delivery --

  test "open_scheduled_polls delivers emails to voters when notify_on_open is true" do
    member = create_unique_user("emailvoter")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_operator announced_emails.size, :>=, 1,
      "voter should receive email when poll opens with notify_on_open=true"
  end

  test "open_scheduled_polls delivers no emails to voters when notify_on_open is false" do
    member = create_unique_user("noemailvoter")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    ), actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_equal 0, announced_emails.size,
      "voter should not receive email when poll opens with notify_on_open=false"
  end

  # -- group_members_added --

  test "adds new group members to non-specified-voters-only polls" do
    poll = create_poll(specified_voters_only: false)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    new_member = create_unique_user("newgroupmember")
    Membership.create!(user: new_member, group: @group, accepted_at: Time.current)
    PollService.group_members_added(@group.id)
    assert_equal count + 1, poll.voters.count
  end

  test "adds new group members to active anonymous polls after voting starts" do
    poll = create_poll(specified_voters_only: false, anonymous: true)
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id, score: 1 }]
      ),
      actor: @user
    )
    voters_count = poll.reload.voters_count
    undecided_voters_count = poll.undecided_voters_count

    new_member = create_unique_user("newanonymousmember")
    Membership.create!(user: new_member, group: @group, accepted_at: Time.current)
    PollService.group_members_added(@group.id)

    assert poll.anonymous_poll_voters.exists?(voter: new_member, ballot_submitted: false)
    assert_equal voters_count + 1, poll.reload.voters_count
    assert_equal undecided_voters_count + 1, poll.undecided_voters_count
  end

  test "does not add bot users to polls" do
    poll = create_poll(specified_voters_only: false)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    bot = User.create!(name: 'Bot', email: "bot#{SecureRandom.hex(4)}@example.com",
                       email_verified: true, username: "bot#{SecureRandom.hex(4)}", bot: true)
    Membership.create!(user: bot, group: @group, accepted_at: Time.current)
    PollService.group_members_added(@group.id)
    assert_equal count, poll.voters.count
  end

  test "creates public topic when group requires public discussions" do
    open_group = Group.new(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    open_group.save!
    Membership.create!(user: @user, group: open_group, accepted_at: Time.current, admin: true)

    poll = PollService.create(
      params: poll_params(group_id: open_group.id),
      actor: @user
    )

    assert open_group.public_discussions_only?, "group should require public discussions"
    assert_equal false, poll.topic.private, "topic should be public for an open group"
  end

  private

  def poll_params(overrides = {})
    {
      title: "Test Poll #{SecureRandom.hex(4)}",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      group_id: @group.id
    }.merge(overrides)
  end

  def create_poll(overrides = {})
    PollService.create(params: poll_params(overrides), actor: @user)
  end

  def create_unique_user(prefix)
    User.create!(
      name: prefix.titleize,
      email: "#{prefix}#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "#{prefix}#{SecureRandom.hex(4)}"
    )
  end
end
