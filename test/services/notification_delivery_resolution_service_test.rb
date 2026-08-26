require "test_helper"

class NotificationDeliveryResolverTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @author = users(:user)
    @poll = PollService.create(
      params: {
        title: "Resolution test poll",
        poll_type: "proposal",
        poll_option_names: [ "Yes", "No" ],
        closing_at: 3.days.from_now,
        group_id: groups(:group).id
      },
      actor: @author
    )
    @outcome = Outcome.create!(
      poll: @poll,
      author: @author,
      statement: "Resolution test outcome",
      review_on: Date.current
    )
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot = Chatbot.create!(
        group: @outcome.group,
        author: users(:admin),
        name: "Resolution test chatbot",
        server: "https://resolution-test.example.test/hook",
        webhook_kind: "markdown",
        kind: "webhook",
        event_kinds: [ "outcome_review_due" ]
      )
    end
  end

  test "every supported notification kind has an explicit resolver contract" do
    expected = {
      "comment_replied_to" => NotificationDeliveryResolvers::UserMentioned,
      "discussion_announced" => NotificationDeliveryResolvers::DiscussionAnnounced,
      "discussion_edited" => NotificationDeliveryResolvers::DiscussionEdited,
      "group_mentioned" => NotificationDeliveryResolvers::GroupMentioned,
      "invitation_accepted" => NotificationDeliveryResolvers::InvitationAccepted,
      "membership_created" => NotificationDeliveryResolvers::MembershipCreated,
      "membership_resent" => NotificationDeliveryResolvers::MembershipResent,
      "membership_request_approved" => NotificationDeliveryResolvers::MembershipRequestApproved,
      "membership_requested" => NotificationDeliveryResolvers::MembershipRequested,
      "new_coordinator" => NotificationDeliveryResolvers::NewCoordinator,
      "new_delegate" => NotificationDeliveryResolvers::NewDelegate,
      "new_discussion" => NotificationDeliveryResolvers::NewDiscussion,
      "outcome_announced" => NotificationDeliveryResolvers::OutcomeAnnounced,
      "outcome_created" => NotificationDeliveryResolvers::OutcomeChange,
      "outcome_review_due" => NotificationDeliveryResolvers::OutcomeReviewDue,
      "outcome_updated" => NotificationDeliveryResolvers::OutcomeChange,
      "poll_announced" => NotificationDeliveryResolvers::PollAnnounced,
      "poll_closing_soon" => NotificationDeliveryResolvers::PollClosingSoon,
      "poll_edited" => NotificationDeliveryResolvers::PollEdited,
      "poll_expired" => NotificationDeliveryResolvers::PollExpired,
      "poll_reminder" => NotificationDeliveryResolvers::PollReminder,
      "reaction_created" => NotificationDeliveryResolvers::ReactionCreated,
      "unknown_sender" => NotificationDeliveryResolvers::UnknownSender,
      "user_added_to_group" => NotificationDeliveryResolvers::UserAddedToGroup,
      "user_mentioned" => NotificationDeliveryResolvers::UserMentioned
    }

    assert_equal expected.keys.sort, NotificationDeliveryResolver::RESOLVERS.keys.sort
    expected.each do |kind, resolver_class|
      assert_equal resolver_class, NotificationDeliveryResolver.class_for(kind), kind
    end
  end

  test "typed resolvers reject a subject from the wrong domain" do
    wrong_subjects = {
      "discussion_announced" => @poll,
      "discussion_edited" => @poll,
      "invitation_accepted" => @poll,
      "membership_created" => @poll,
      "membership_resent" => @poll,
      "membership_request_approved" => @poll,
      "membership_requested" => @poll,
      "new_coordinator" => @poll,
      "new_delegate" => @poll,
      "new_discussion" => @poll,
      "outcome_announced" => @poll,
      "outcome_created" => @poll,
      "outcome_review_due" => @poll,
      "outcome_updated" => @poll,
      "poll_announced" => @outcome,
      "poll_closing_soon" => @outcome,
      "poll_edited" => @outcome,
      "poll_expired" => @outcome,
      "poll_reminder" => @outcome,
      "reaction_created" => @poll,
      "unknown_sender" => @poll,
      "user_added_to_group" => @poll
    }

    wrong_subjects.each do |kind, subject|
      error = assert_raises(ArgumentError, kind) do
        resolve_notification(kind: kind, subject: subject)
      end
      assert_match(/subject must be/, error.message, kind)
    end
  end

  test "explicit audience resolvers deliver to a normal-volume eligible user" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, email_when_mentioned: true, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussions(:discussion).topic).set_volume!(:normal)
    TopicReader.for(user: recipient, topic: @poll.topic).set_volume!(:normal)

    scenarios = {
      "comment_replied_to" => discussions(:discussion),
      "discussion_announced" => discussions(:discussion),
      "discussion_edited" => discussions(:discussion),
      "membership_created" => groups(:group),
      "new_discussion" => discussions(:discussion),
      "outcome_announced" => @outcome,
      "outcome_created" => @outcome,
      "outcome_updated" => @outcome,
      "poll_announced" => @poll,
      "poll_edited" => @poll,
      "poll_reminder" => @poll,
      "user_mentioned" => discussions(:discussion)
    }

    scenarios.each do |kind, subject|
      notification = resolve_notification(
        kind: kind,
        subject: subject,
        recipient_user_ids: [ recipient.id ]
      )

      assert_equal %w[email in_app], channels_for(notification, recipient), kind
    end
  end

  test "direct operational resolvers preserve their recipient and channel rules" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    membership = memberships(:member_membership)
    membership.update!(inviter: @author, volume: :normal)

    scenarios = {
      "invitation_accepted" => [ membership, @author, %w[in_app] ],
      "membership_request_approved" => [ membership, recipient, %w[email in_app] ],
      "membership_resent" => [ membership, recipient, %w[email] ],
      "new_coordinator" => [ membership, recipient, %w[in_app] ],
      "new_delegate" => [ membership, recipient, %w[email in_app] ],
      "user_added_to_group" => [ membership, recipient, %w[email in_app] ]
    }

    scenarios.each do |kind, (subject, expected_recipient, expected_channels)|
      notification = resolve_notification(kind: kind, subject: subject)
      assert_equal expected_channels, channels_for(notification, expected_recipient), kind
    end
  end

  test "derived audience resolvers cover requests, reactions, unknown senders and group mentions" do
    admin = users(:admin)
    admin.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    groups(:group).membership_for(admin).update!(volume: :normal)

    requestor = users(:alien)
    request = MembershipRequest.create!(
      group: groups(:group),
      requestor: requestor,
      introduction: "Please add me"
    )
    requested = resolve_notification(kind: "membership_requested", subject: request, actor: requestor)
    assert_equal %w[email in_app], channels_for(requested, admin)

    reaction = Reaction.create!(
      reactable: discussions(:discussion),
      user: @author,
      reaction: "smiley"
    )
    reacted = resolve_notification(kind: "reaction_created", subject: reaction)
    assert_equal %w[in_app], channels_for(reacted, discussions(:discussion).author)

    received_email = ReceivedEmail.create!(group: groups(:group), headers: {})
    unknown_sender = resolve_notification(kind: "unknown_sender", subject: received_email)
    assert_equal %w[in_app], channels_for(unknown_sender, admin)

    member = users(:member)
    member.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    groups(:group).membership_for(member).update!(volume: :normal)
    group_mentioned = resolve_notification(
      kind: "group_mentioned",
      subject: discussions(:discussion),
      audience_values: {
        "group_ids" => [ groups(:group).id ],
        "mentioned_user_ids" => [],
        "already_notified_user_ids" => []
      }
    )
    assert_equal %w[email in_app], channels_for(group_mentioned, member)
    assert_empty channels_for(group_mentioned, @author)
  end

  test "scheduled resolver matrix preserves author and voter delivery rules" do
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(:normal)
    @author.update!(deactivated_at: nil, complaints_count: 0)

    review_due = resolve_notification(kind: "outcome_review_due", subject: @outcome)
    assert_equal %w[email in_app], channels_for(review_due, @author)

    @poll.update!(notify_on_closing_soon: "author")
    closing_for_author = resolve_notification(kind: "poll_closing_soon", subject: @poll)
    assert_equal %w[email], channels_for(closing_for_author, @author)

    voter = users(:member)
    voter.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: voter, topic: @poll.topic).set_volume!(:normal)
    stance = Stance.latest.find_or_initialize_by(poll: @poll, participant: voter)
    stance.update!(choice: "Yes", cast_at: Time.current)
    @poll.update!(notify_on_closing_soon: "voters")
    closing_for_voters = resolve_notification(kind: "poll_closing_soon", subject: @poll)
    assert_equal %w[email in_app], channels_for(closing_for_voters, voter)

    expired = resolve_notification(kind: "poll_expired", subject: @poll)
    assert_equal %w[email in_app], channels_for(expired, @author)
  end

  test "topic audience boundaries filter volume, account state, complaints and duplicate email paths" do
    discussion = discussions(:discussion)
    recipient_attributes = {
      normal: { volume: :normal },
      quiet: { volume: :quiet },
      muted: { volume: :mute },
      complained: { volume: :normal, complaints_count: 1 },
      inactive: { volume: :normal, deactivated_at: Time.current },
      mentioned: { volume: :normal },
      loud: { volume: :loud }
    }
    recipients = recipient_attributes.transform_values do |attributes|
      volume = attributes.delete(:volume)
      user = create_resolver_user(**attributes)
      groups(:group).add_member!(user)
      TopicReader.for(user: user, topic: discussion.topic).set_volume!(volume)
      user
    end

    notification = resolve_notification(
      kind: "discussion_edited",
      subject: discussion,
      recipient_user_ids: recipients.values.map(&:id),
      recipient_message: "Please review",
      audience_values: { "newly_mentioned_user_ids" => [ recipients[:mentioned].id ] }
    )

    assert_equal %w[email in_app], channels_for(notification, recipients[:normal])
    assert_equal %w[in_app], channels_for(notification, recipients[:quiet])
    assert_empty channels_for(notification, recipients[:muted])
    assert_equal %w[in_app], channels_for(notification, recipients[:complained])
    assert_empty channels_for(notification, recipients[:inactive])
    assert_equal %w[in_app], channels_for(notification, recipients[:mentioned])
    assert_equal %w[in_app], channels_for(notification, recipients[:loud])
  end

  test "chatbot resolver matrix distinguishes implicit subscriptions from explicit selection" do
    implicit_kinds = %w[
      discussion_announced outcome_review_due poll_announced poll_closing_soon
      poll_expired poll_reminder
    ]
    explicit_kinds = %w[
      discussion_edited new_discussion outcome_created outcome_updated poll_edited
    ]
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot.update!(event_kinds: implicit_kinds)
    end
    @poll.update!(notify_on_closing_soon: "author")

    subjects = {
      "discussion_announced" => discussions(:discussion),
      "discussion_edited" => discussions(:discussion),
      "new_discussion" => discussions(:discussion),
      "outcome_created" => @outcome,
      "outcome_review_due" => @outcome,
      "outcome_updated" => @outcome,
      "poll_announced" => @poll,
      "poll_closing_soon" => @poll,
      "poll_edited" => @poll,
      "poll_expired" => @poll,
      "poll_reminder" => @poll
    }

    implicit_kinds.each do |kind|
      notification = resolve_notification(kind: kind, subject: subjects.fetch(kind))
      assert_equal %w[chatbot], channels_for(notification, @chatbot), kind
    end

    explicit_kinds.each do |kind|
      without_selection = resolve_notification(kind: kind, subject: subjects.fetch(kind))
      assert_empty channels_for(without_selection, @chatbot), kind

      with_selection = resolve_notification(
        kind: kind,
        subject: subjects.fetch(kind),
        recipient_chatbot_ids: [ @chatbot.id ]
      )
      assert_equal %w[chatbot], channels_for(with_selection, @chatbot), kind
    end
  end

  test "a newly committed notification resolves user and chatbot deliveries in the background" do
    notification = nil
    assert_enqueued_with(job: ResolveNotificationDeliveriesWorker) do
      notification = create_notification
    end

    assert_nil notification.deliveries_generated_at

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    deliveries = notification.reload.notification_deliveries
    assert_not_nil notification.deliveries_generated_at
    assert_equal %w[chatbot email in_app], deliveries.order(:channel).pluck(:channel)
    assert_equal [ @author.id ], deliveries.where(channel: %w[email in_app]).distinct.pluck(:recipient_id)
    assert_equal [ @chatbot.id ], deliveries.where(channel: "chatbot").pluck(:recipient_id)
    assert_equal "delivered", deliveries.find_by!(channel: "in_app").status
    assert_equal %w[pending pending], deliveries.where.not(channel: "in_app").pluck(:status)
  end

  test "resolver retries preserve one delivery identity" do
    notification = create_notification
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_no_difference "NotificationDelivery.count" do
      ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    end
  end

  test "an outcome review email renders once and completes delivery" do
    notification = create_notification
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    delivery = notification.notification_deliveries.find_by!(channel: "email")

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      DeliverNotificationEmailWorker.perform_now(delivery.id)
      DeliverNotificationEmailWorker.perform_now(delivery.id)
    end

    assert_equal "delivered", delivery.reload.status
    assert_includes ActionMailer::Base.deliveries.last.to, @author.email
  end

  test "an outcome review chatbot renders once and completes delivery" do
    notification = create_notification
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    delivery = notification.notification_deliveries.find_by!(channel: "chatbot")
    webhook_url = @chatbot.server
    WebMock.stub_request(:post, webhook_url).to_return(status: 200)

    Resolv.stub(:getaddresses, [ "93.184.216.34" ]) do
      DeliverNotificationChatbotWorker.perform_now(delivery.id)
      DeliverNotificationChatbotWorker.perform_now(delivery.id)
    end

    assert_requested :post, webhook_url, times: 1
    assert_equal "delivered", delivery.reload.status
  end

  test "the pending dispatcher recovers channel deliveries after an enqueue gap" do
    notification = create_notification
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    clear_enqueued_jobs

    DispatchPendingNotificationDeliveriesWorker.perform_now

    email_delivery = notification.notification_deliveries.find_by!(channel: "email")
    chatbot_delivery = notification.notification_deliveries.find_by!(channel: "chatbot")
    assert_enqueued_with(job: DeliverNotificationEmailWorker, args: [ email_delivery.id ])
    assert_enqueued_with(job: DeliverNotificationChatbotWorker, args: [ chatbot_delivery.id ])
  end

  test "the pending dispatcher releases and re-enqueues a stale claim" do
    notification = create_notification
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    delivery = notification.notification_deliveries.find_by!(channel: "email")
    delivery.update!(status: "claimed", claimed_at: 16.minutes.ago)
    clear_enqueued_jobs

    DispatchPendingNotificationDeliveriesWorker.perform_now

    assert_equal "pending", delivery.reload.status
    assert_nil delivery.claimed_at
    assert_enqueued_with(job: DeliverNotificationEmailWorker, args: [ delivery.id ])
  end

  test "the global creator requires a persisted occurrence identity" do
    assert_raises(ArgumentError) do
      NotificationService.create!(
        kind: "outcome_review_due",
        subject: Outcome.new,
        actor: @author
      )
    end
  end

  test "the shared creator snapshots an explicit audience for its resolver" do
    notification = NotificationService.create!(
      kind: "outcome_review_due",
      subject: @outcome,
      actor: @author,
      recipient_user_ids: [ @author.id, @author.id ],
      recipient_chatbot_ids: [ @chatbot.id ]
    )

    assert_equal [ @author.id ], notification.recipient_user_ids
    assert_equal [ @chatbot.id ], notification.recipient_chatbot_ids
  end

  test "discussion announcements use the shared creator with an explicit audience" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(:normal)

    notification = NotificationService.create!(
      kind: "discussion_announced",
      subject: discussion,
      actor: @author,
      recipient_user_ids: [ recipient.id ],
      recipient_chatbot_ids: [ @chatbot.id ],
      recipient_message: "Please review this thread"
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal "Please review this thread", notification.recipient_message
    assert_equal %w[chatbot email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal 1, Notification.where(kind: "discussion_announced", subject: discussion).count

    delivery = notification.notification_deliveries.find_by!(channel: "email")
    DeliverNotificationEmailWorker.perform_now(delivery.id)
    assert_includes ActionMailer::Base.deliveries.last.html_part.body.to_s, "Please review this thread"
  end

  test "an explicitly selected chatbot uses notification delivery for an eventless edit" do
    discussion = discussions(:discussion)

    assert_no_difference -> { TopicItem.where(kind: "discussion_edited").count } do
      DiscussionService.update(
        discussion: discussion,
        actor: @author,
        params: {
          title: "Direct chatbot edit",
          recipient_chatbot_ids: [ @chatbot.id ]
        }
      )
    end

    notification = Notification.find_by!(kind: "discussion_edited", subject: discussion)
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [ @chatbot.id ], notification.notification_deliveries
                                             .where(channel: "chatbot")
                                             .pluck(:recipient_id)
  end

  test "new discussion notifications use their timeline topic item as the subject" do
    recipient = users(:member)
    discussion = DiscussionService.create(
      params: {
        title: "Notification delivery discussion",
        group_id: groups(:group).id,
        recipient_user_ids: [ recipient.id ],
        recipient_chatbot_ids: [ @chatbot.id ],
        recipient_message: "Please review this discussion"
      },
      actor: @author
    )
    topic_item = TopicItems::NewDiscussion.find(discussion.created_topic_item.id)
    notification = Notification.find_by!(kind: "new_discussion", subject: topic_item)

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal [ @chatbot.id ], notification.recipient_chatbot_ids
    assert_equal "Please review this discussion", notification.recipient_message
    assert_equal 1, Notification.where(kind: "new_discussion", subject: topic_item).count
    assert_equal %w[chatbot email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "a loud explicit discussion recipient receives one subscription email path" do
    recipient = users(:member)
    recipient.memberships.find_by!(group: groups(:group)).update!(volume: :loud)
    discussion = DiscussionService.create(
      params: {
        title: "Loud recipient discussion",
        group_id: groups(:group).id,
        recipient_user_ids: [ recipient.id ]
      },
      actor: @author
    )
    topic_item = TopicItems::NewDiscussion.find(discussion.created_topic_item.id)
    notification = Notification.find_by!(kind: "new_discussion", subject: topic_item)

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_enqueued_email_with(
      NotificationMailer,
      :topic_item,
      args: [ recipient.id, topic_item.id ]
    ) do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
  end

  test "a loud explicit discussion edit recipient receives one subscription email path" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(:loud)

    topic_item = DiscussionService.update(
      discussion: discussion,
      actor: @author,
      params: {
        recipient_user_ids: [ recipient.id ],
        recipient_message: "Please review this edit"
      }
    )
    notification = Notification.find_by!(kind: "discussion_edited", subject: topic_item)

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_enqueued_email_with(
      NotificationMailer,
      :topic_item,
      args: [ recipient.id, topic_item.id ]
    ) do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
  end

  test "poll closing soon resolves voter channels with recipient-localized values" do
    normal_user = users(:member)
    @poll.update!(notify_on_closing_soon: "voters")
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(:quiet)
    TopicReader.for(user: normal_user, topic: @poll.topic).set_volume!(:normal)
    @author.update!(selected_locale: "en")
    normal_user.update!(selected_locale: "es")
    [ @author, normal_user ].each do |participant|
      stance = Stance.latest.find_or_initialize_by(poll: @poll, participant: participant)
      stance.update!(choice: "Yes", cast_at: Time.current)
    end

    notification = NotificationService.create!(
      kind: "poll_closing_soon",
      subject: @poll,
      actor: @poll.author
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    deliveries = notification.notification_deliveries
    in_app_recipient_ids = deliveries.where(channel: "in_app").pluck(:recipient_id)
    email_recipient_ids = deliveries.where(channel: "email").pluck(:recipient_id)
    assert_includes in_app_recipient_ids, @author.id
    assert_includes in_app_recipient_ids, normal_user.id
    assert_not_includes email_recipient_ids, @author.id
    assert_includes email_recipient_ids, normal_user.id
    spanish_delivery = deliveries.find_by!(channel: "in_app", recipient: normal_user)
    assert_equal @author.name, spanish_delivery.translation_values["name"]
    assert_equal I18n.t("poll_types.#{@poll.poll_type}", locale: :es),
                 spanish_delivery.translation_values["poll_type"]
  end

  test "the scheduled non-anonymous closing reminder creates no topic_item and is idempotent" do
    now = Time.current.beginning_of_hour
    @poll.update!(
      closing_at: now + 1.day,
      notify_on_closing_soon: "author"
    )

    travel_to(now) do
      assert_difference "Notification.count", 1 do
        assert_no_difference -> { TopicItem.where(kind: "poll_closing_soon").count } do
          PollService.publish_closing_soon(now: now)
        end
      end

      assert_no_difference [ "Notification.count", -> { TopicItem.where(kind: "poll_closing_soon").count } ] do
        PollService.publish_closing_soon(now: now)
      end
    end
  end

  test "an extended poll gets a closing reminder for the new deadline" do
    first_closing_at = 1.day.from_now.beginning_of_hour
    @poll.update!(closing_at: first_closing_at, notify_on_closing_soon: "author")

    travel_to(first_closing_at - 1.day) do
      PollService.publish_closing_soon
    end

    second_closing_at = first_closing_at + 2.days
    @poll.update!(closing_at: second_closing_at)

    travel_to(second_closing_at - 1.day) do
      assert_difference -> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }, 1 do
        PollService.publish_closing_soon
      end
    end
  end

  test "poll expiry always creates in-app for the author and applies email volume" do
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(:quiet)
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot.update!(event_kinds: @chatbot.event_kinds + [ "poll_expired" ])
    end
    @poll.update_column(:closed_at, Time.current)

    notification = NotificationService.create!(
      kind: "poll_expired",
      subject: @poll,
      actor: @poll.author
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    deliveries = notification.notification_deliveries
    assert_equal [ @author.id ], deliveries.where(channel: "in_app").pluck(:recipient_id)
    assert_empty deliveries.where(channel: "email")
    assert_equal [ @chatbot.id ], deliveries.where(channel: "chatbot").pluck(:recipient_id)
  end

  test "the non-anonymous expiry worker creates no topic_item" do
    @poll.update_column(:closing_at, 1.hour.ago)

    assert_difference "Notification.count", 1 do
      assert_no_difference -> { TopicItem.where(kind: "poll_expired").count } do
        CloseExpiredPollWorker.perform_now(@poll.id)
      end
    end

    assert Notification.exists?(kind: "poll_expired", subject: @poll)

    assert_no_difference [ "Notification.count", -> { TopicItem.where(kind: "poll_expired").count } ] do
      CloseExpiredPollWorker.perform_now(@poll.id)
    end
  end

  test "an expiry worker retry repairs notification after closing committed" do
    @poll.update_column(:closing_at, 1.hour.ago)
    PollService.do_closing_work(poll: @poll)

    assert @poll.reload.closed_at
    assert_not Notification.exists?(kind: "poll_expired", subject: @poll)

    assert_difference "Notification.count", 1 do
      CloseExpiredPollWorker.perform_now(@poll.id)
    end
  end

  test "a reopened poll gets an expiry notification for its new closing" do
    first_closing_at = 1.hour.ago
    @poll.update_column(:closing_at, first_closing_at)
    CloseExpiredPollWorker.perform_now(@poll.id)

    second_closing_at = 1.hour.from_now
    @poll.update_columns(closed_at: nil, closing_at: second_closing_at)

    travel_to(second_closing_at + 1.minute) do
      assert_difference -> { Notification.where(kind: "poll_expired", subject: @poll).count }, 1 do
        CloseExpiredPollWorker.perform_now(@poll.id)
      end
    end
  end

  private

  def resolve_notification(kind:, subject:, actor: @author, recipient_user_ids: [],
                           recipient_chatbot_ids: [], recipient_message: nil, audience_values: {})
    notification = Notification.create!(
      kind: kind,
      subject: subject,
      actor: actor,
      recipient_user_ids: recipient_user_ids,
      recipient_chatbot_ids: recipient_chatbot_ids,
      recipient_message: recipient_message,
      audience_values: audience_values
    )
    NotificationDeliveryResolver.for(notification).resolve!
    notification
  end

  def channels_for(notification, recipient)
    notification.notification_deliveries
                .where(recipient: recipient)
                .order(:channel)
                .pluck(:channel)
  end

  def create_resolver_user(complaints_count: 0, deactivated_at: nil)
    token = SecureRandom.hex(5)
    User.create!(
      name: "Resolver #{token}",
      email: "resolver-#{token}@example.test",
      email_verified: true,
      complaints_count: complaints_count,
      deactivated_at: deactivated_at
    )
  end

  def create_notification
    NotificationService.create!(
      kind: "outcome_review_due",
      subject: @outcome,
      actor: @outcome.author
    )
  end
end
