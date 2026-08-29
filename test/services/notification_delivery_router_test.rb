require "test_helper"

class NotificationDeliveryRouterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @author = users(:user)
    @poll = PollService.create(
      params: {
        title: "Routing test poll",
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
      statement: "Routing test outcome",
      review_on: Date.current
    )
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot = Chatbot.create!(
        group: @outcome.group,
        author: users(:admin),
        name: "Routing test chatbot",
        server: "https://routing-test.example.test/hook",
        webhook_kind: "markdown",
        kind: "webhook",
        event_kinds: [ "outcome_review_due" ]
      )
    end
  end

  test "every supported notification kind has a router" do
    expected = {
      "comment_replied_to" => NotificationDeliveryRouters::UserMentioned,
      "discussion_announced" => NotificationDeliveryRouters::DiscussionEvent,
      "discussion_edited" => NotificationDeliveryRouters::DiscussionEvent,
      "group_mentioned" => NotificationDeliveryRouters::GroupMentioned,
      "invitation_accepted" => NotificationDeliveryRouters::InvitationAccepted,
      "membership_created" => NotificationDeliveryRouters::MembershipCreated,
      "membership_resent" => NotificationDeliveryRouters::MembershipResent,
      "membership_request_approved" => NotificationDeliveryRouters::MembershipRequestApproved,
      "membership_requested" => NotificationDeliveryRouters::MembershipRequested,
      "new_coordinator" => NotificationDeliveryRouters::NewCoordinator,
      "new_delegate" => NotificationDeliveryRouters::NewDelegate,
      "new_discussion" => NotificationDeliveryRouters::DiscussionEvent,
      "outcome_announced" => NotificationDeliveryRouters::OutcomeAnnounced,
      "outcome_created" => NotificationDeliveryRouters::OutcomeChange,
      "outcome_review_due" => NotificationDeliveryRouters::OutcomeReviewDue,
      "outcome_updated" => NotificationDeliveryRouters::OutcomeChange,
      "poll_announced" => NotificationDeliveryRouters::PollAnnounced,
      "poll_closing_soon" => NotificationDeliveryRouters::PollClosingSoon,
      "poll_edited" => NotificationDeliveryRouters::PollEdited,
      "poll_expired" => NotificationDeliveryRouters::PollExpired,
      "poll_reminder" => NotificationDeliveryRouters::PollReminder,
      "reaction_created" => NotificationDeliveryRouters::ReactionCreated,
      "unknown_sender" => NotificationDeliveryRouters::UnknownSender,
      "user_added_to_group" => NotificationDeliveryRouters::UserAddedToGroup,
      "user_mentioned" => NotificationDeliveryRouters::UserMentioned
    }

    assert_equal expected.keys.sort, NotificationDeliveryRouter::ROUTERS.keys.sort
    expected.each do |kind, router_class|
      assert_equal router_class, NotificationDeliveryRouter.class_for(kind), kind
      assert router_class.subject_model_class, kind
    end
  end

  test "typed routers reject a subject from the wrong domain" do
    wrong_subjects = {
      "discussion_announced" => @poll,
      "discussion_edited" => @poll,
      "group_mentioned" => memberships(:member_membership),
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
      "user_added_to_group" => @poll,
      "user_mentioned" => memberships(:member_membership),
      "comment_replied_to" => memberships(:member_membership)
    }

    wrong_subjects.each do |kind, subject|
      error = assert_raises(ArgumentError, kind) do
        route_notification(kind: kind, subject: subject)
      end
      assert_match(/subject must be/, error.message, kind)
    end
  end

  test "selected-recipient routers deliver to a normal-volume eligible user" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussions(:discussion).topic).set_volume!(email: :normal, push: :quiet)
    TopicReader.for(user: recipient, topic: @poll.topic).set_volume!(email: :normal, push: :quiet)

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
      notification = route_notification(
        kind: kind,
        subject: subject,
        recipient_user_ids: [ recipient.id ]
      )

      assert_equal %w[email in_app], channels_for(notification, recipient), kind
    end
  end

  test "directed notifications create push deliveries only for push channels" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, complaints_count: 0)
    reader = TopicReader.for(user: recipient, topic: discussions(:discussion).topic)
    reader.set_volume!(email: :quiet, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/router-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    notification = route_notification(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ],
      recipient_message: "Please review"
    )

    assert_equal %w[in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)

    mention = route_notification(
      kind: "user_mentioned",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ]
    )
    assert_equal %w[in_app], channels_for(mention, recipient)
    assert_equal [ "push" ], channels_for(mention, subscription)

    reader.set_volume!(email: :normal, push: :quiet)
    next_notification = route_notification(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ],
      recipient_message: "Please review again"
    )

    assert_empty channels_for(next_notification, subscription)
  end

  test "volume scopes cannot add recipients outside the in-app recipients" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    outside_recipient = users(:admin)
    [ recipient, outside_recipient ].each do |user|
      user.update!(deactivated_at: nil)
      TopicReader.for(user: user, topic: discussion.topic)
                 .set_volume!(email: :normal, push: :normal)
    end
    recipient_subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/audience-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    outside_subscription = create_push_subscription(
      user: outside_recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/outside-recipient-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    notification = route_notification(
      kind: "discussion_edited",
      subject: discussion,
      recipient_user_ids: [ recipient.id ]
    )

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, recipient_subscription)
    assert_empty channels_for(notification, outside_recipient)
    assert_empty channels_for(notification, outside_subscription)
  end

  test "notification push delivery rechecks the recipient before sending" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussions(:discussion).topic)
               .set_volume!(email: :quiet, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/policy-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    notification = route_notification(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ]
    )
    delivery = notification.notification_deliveries.find_by!(recipient: subscription, channel: "push")
    recipient.update!(deactivated_at: Time.current)

    WebPushService.stub(:deliver!, ->(**) { flunk "push should not be sent" }) do
      DeliverNotificationPushWorker.perform_now(delivery.id)
    end

    assert_equal "cancelled", delivery.reload.status
  end

  test "notification push delivery cancels when its session has been revoked" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussions(:discussion).topic)
               .set_volume!(email: :quiet, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/revoked-session-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    notification = route_notification(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ]
    )
    delivery = notification.notification_deliveries.find_by!(recipient: subscription, channel: "push")
    subscription.session.destroy!

    WebPushService.stub(:deliver!, ->(**) { flunk "push should not be sent" }) do
      DeliverNotificationPushWorker.perform_now(delivery.id)
    end

    assert_equal "cancelled", delivery.reload.status
  end

  test "notification push delivery cancels an expired subscription" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussions(:discussion).topic)
               .set_volume!(email: :quiet, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/expiry-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    notification = route_notification(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      recipient_user_ids: [ recipient.id ]
    )
    delivery = notification.notification_deliveries.find_by!(recipient: subscription, channel: "push")
    subscription.update!(expires_at: 1.minute.ago)

    DeliverNotificationPushWorker.perform_now(delivery.id)

    assert_equal "cancelled", delivery.reload.status
  end

  test "direct operational routers preserve their recipient and channel rules" do
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    membership = memberships(:member_membership)
    membership.update!(inviter: @author, volume_email: :normal)

    scenarios = {
      "invitation_accepted" => [ membership, @author, %w[in_app] ],
      "membership_request_approved" => [ membership, recipient, %w[in_app] ],
      "membership_resent" => [ membership, recipient, %w[email] ],
      "new_coordinator" => [ membership, recipient, %w[email in_app] ],
      "new_delegate" => [ membership, recipient, %w[email in_app] ],
      "user_added_to_group" => [ membership, recipient, %w[email in_app] ]
    }

    scenarios.each do |kind, (subject, expected_recipient, expected_channels)|
      notification = route_notification(kind: kind, subject: subject)
      assert_equal expected_channels, channels_for(notification, expected_recipient), kind
    end
  end

  test "in-app-only routers do not opt into email or push" do
    membership = memberships(:member_membership)
    recipient = membership.user
    membership.update!(inviter: @author, volume_email: :normal, volume_push: :normal)
    membership.group.membership_for(@author).update!(volume_email: :normal, volume_push: :normal)
    recipient.update!(deactivated_at: nil, complaints_count: 0)
    @author.update!(deactivated_at: nil, complaints_count: 0)
    recipient_subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/approved-in-app-only-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    inviter_subscription = create_push_subscription(
      user: @author,
      endpoint: "https://fcm.googleapis.com/fcm/send/accepted-in-app-only-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    approved = route_notification(kind: "membership_request_approved", subject: membership)
    accepted = route_notification(kind: "invitation_accepted", subject: membership)

    assert_equal [ "in_app" ], channels_for(approved, recipient)
    assert_empty channels_for(approved, recipient_subscription)
    assert_equal [ "in_app" ], channels_for(accepted, @author)
    assert_empty channels_for(accepted, inviter_subscription)
  end

  test "coordinator and delegate role changes share email and push volume behavior" do
    membership = memberships(:member_membership)
    recipient = membership.user
    membership.update!(volume_email: :normal, volume_push: :normal)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/role-change-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    %w[new_coordinator new_delegate].each do |kind|
      notification = route_notification(kind: kind, subject: membership)
      assert_equal %w[email in_app], channels_for(notification, recipient), kind
      assert_equal [ "push" ], channels_for(notification, subscription), kind
    end
  end

  test "derived-recipient routers cover requests, reactions, unknown senders and group mentions" do
    admin = users(:admin)
    admin.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    groups(:group).membership_for(admin).update!(volume_email: :normal, volume_push: :normal)
    admin_subscription = create_push_subscription(
      user: admin,
      endpoint: "https://fcm.googleapis.com/fcm/send/derived-admin-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    requestor = users(:alien)
    request = MembershipRequest.create!(
      group: groups(:group),
      requestor: requestor,
      introduction: "Please add me"
    )
    requested = route_notification(kind: "membership_requested", subject: request, actor: requestor)
    assert_equal %w[email in_app], channels_for(requested, admin)

    reaction = Reaction.create!(
      reactable: discussions(:discussion),
      user: @author,
      reaction: "smiley"
    )
    reaction_recipient = discussions(:discussion).author
    reaction_recipient.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: reaction_recipient, topic: discussions(:discussion).topic)
               .set_volume!(email: :normal, push: :normal)
    reaction_subscription = create_push_subscription(
      user: reaction_recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/reaction-volume-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    reacted = route_notification(kind: "reaction_created", subject: reaction)
    assert_equal [ "in_app" ], channels_for(reacted, reaction_recipient)
    assert_empty channels_for(reacted, reaction_subscription)

    received_email = ReceivedEmail.create!(group: groups(:group), headers: {})
    unknown_sender = route_notification(kind: "unknown_sender", subject: received_email)
    assert_equal [ "in_app" ], channels_for(unknown_sender, admin)
    assert_empty channels_for(unknown_sender, admin_subscription)

    member = users(:member)
    member.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    groups(:group).membership_for(member).update!(volume_email: :normal)
    group_mentioned = route_notification(
      kind: "group_mentioned",
      subject: discussions(:discussion),
      recipient_context: {
        "group_ids" => [ groups(:group).id ],
        "mentioned_user_ids" => [],
        "already_notified_user_ids" => []
      }
    )
    assert_equal %w[email in_app], channels_for(group_mentioned, member)
    assert_empty channels_for(group_mentioned, @author)
  end

  test "group mentions use the mentioned group volume for both external channels" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    groups(:group).membership_for(recipient).update!(volume_email: :normal, volume_push: :normal)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :quiet, push: :quiet)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/group-mention-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    notification = route_notification(
      kind: "group_mentioned",
      subject: discussion,
      recipient_context: {
        "group_ids" => [ groups(:group).id ],
        "mentioned_user_ids" => [],
        "already_notified_user_ids" => []
      }
    )

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)
  end

  test "scheduled router matrix preserves author and voter delivery rules" do
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(email: :normal, push: :quiet)
    @author.update!(deactivated_at: nil, complaints_count: 0)

    review_due = route_notification(kind: "outcome_review_due", subject: @outcome)
    assert_equal %w[email in_app], channels_for(review_due, @author)

    subscription = create_push_subscription(
      user: @author,
      endpoint: "https://fcm.googleapis.com/fcm/send/scheduled-author-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(email: :normal, push: :normal)
    @poll.update!(notify_on_closing_soon: "author")
    closing_for_author = route_notification(kind: "poll_closing_soon", subject: @poll)
    assert_equal %w[email in_app], channels_for(closing_for_author, @author)
    assert_equal [ "push" ], channels_for(closing_for_author, subscription)

    voter = users(:member)
    voter.update!(deactivated_at: nil, complaints_count: 0)
    TopicReader.for(user: voter, topic: @poll.topic).set_volume!(email: :normal, push: :quiet)
    stance = Stance.latest.find_or_initialize_by(poll: @poll, participant: voter)
    stance.update!(choice: "Yes", cast_at: Time.current)
    @poll.update!(notify_on_closing_soon: "voters")
    closing_for_voters = route_notification(kind: "poll_closing_soon", subject: @poll)
    assert_equal %w[email in_app], channels_for(closing_for_voters, voter)

    expired = route_notification(kind: "poll_expired", subject: @poll)
    assert_equal %w[email in_app], channels_for(expired, @author)
  end

  test "topic recipient boundaries filter volume, account state, complaints and mentions" do
    discussion = discussions(:discussion)
    recipient_attributes = {
      normal: { volume_email: :normal },
      quiet: { volume_email: :quiet },
      complained: { volume_email: :normal, complaints_count: 1 },
      inactive: { volume_email: :normal, deactivated_at: Time.current },
      mentioned: { volume_email: :normal },
      loud: { volume_email: :loud }
    }
    recipients = recipient_attributes.transform_values do |attributes|
      volume_email = attributes.delete(:volume_email)
      user = create_router_user(**attributes)
      groups(:group).add_member!(user)
      TopicReader.for(user: user, topic: discussion.topic).set_volume!(email: volume_email, push: :quiet)
      user
    end

    notification = route_notification(
      kind: "discussion_edited",
      subject: discussion,
      recipient_user_ids: recipients.values.map(&:id),
      recipient_message: "Please review",
      recipient_context: { "newly_mentioned_user_ids" => [ recipients[:mentioned].id ] }
    )

    assert_equal %w[email in_app], channels_for(notification, recipients[:normal])
    assert_equal %w[in_app], channels_for(notification, recipients[:quiet])
    assert_equal %w[in_app], channels_for(notification, recipients[:complained])
    assert_empty channels_for(notification, recipients[:inactive])
    assert_empty channels_for(notification, recipients[:mentioned])
    assert_equal %w[email in_app], channels_for(notification, recipients[:loud])
  end

  test "mentions use the same topic volume source for email and push" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    recipient.update!(
      deactivated_at: nil,
      email_verified: true,
      complaints_count: 0
    )
    TopicReader.for(user: recipient, topic: discussion.topic)
               .set_volume!(email: :normal, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/symmetric-mention-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    notification = route_notification(
      kind: "user_mentioned",
      subject: discussion,
      recipient_user_ids: [ recipient.id ]
    )

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)
  end

  test "a mention occurrence owns every channel for a newly mentioned selected recipient" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    recipient.update!(deactivated_at: nil, email_verified: true, complaints_count: 0)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :normal, push: :normal)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/mention-owner-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    direct = route_notification(
      kind: "discussion_edited",
      subject: discussion,
      recipient_user_ids: [ recipient.id ],
      recipient_message: "Please review",
      recipient_context: { "newly_mentioned_user_ids" => [ recipient.id ] }
    )
    mention = route_notification(
      kind: "user_mentioned",
      subject: discussion,
      recipient_user_ids: [ recipient.id ]
    )

    assert_empty channels_for(direct, recipient)
    assert_empty channels_for(direct, subscription)
    assert_equal %w[email in_app], channels_for(mention, recipient)
    assert_equal [ "push" ], channels_for(mention, subscription)
  end

  test "user-initiated routers exclude their actor from every user channel" do
    scenarios = {
      "discussion_announced" => discussions(:discussion),
      "discussion_edited" => discussions(:discussion),
      "new_discussion" => discussions(:discussion),
      "membership_created" => groups(:group),
      "poll_edited" => @poll,
      "poll_reminder" => @poll
    }

    scenarios.each do |kind, subject|
      notification = route_notification(
        kind: kind,
        subject: subject,
        actor: @author,
        recipient_user_ids: [ @author.id ]
      )
      assert_empty channels_for(notification, @author), kind
    end
  end

  test "outcome routers honor an included actor across channels" do
    TopicReader.for(user: @author, topic: @outcome.topic).set_volume!(email: :normal, push: :normal)
    subscription = create_push_subscription(
      user: @author,
      endpoint: "https://fcm.googleapis.com/fcm/send/outcome-actor-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    %w[outcome_announced outcome_created outcome_updated].each do |kind|
      notification = route_notification(
        kind: kind,
        subject: @outcome,
        actor: @author,
        recipient_user_ids: [ @author.id ]
      )
      assert_equal %w[email in_app], channels_for(notification, @author), kind
      assert_equal [ "push" ], channels_for(notification, subscription), kind
    end
  end

  test "chatbot router matrix distinguishes implicit subscriptions from explicit selection" do
    implicit_kinds = %w[
      outcome_review_due poll_announced poll_closing_soon poll_expired poll_reminder
    ]
    explicit_kinds = %w[
      discussion_announced discussion_edited new_discussion outcome_created
      outcome_updated poll_edited
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
      notification = route_notification(kind: kind, subject: subjects.fetch(kind))
      assert_equal %w[chatbot], channels_for(notification, @chatbot), kind
    end

    explicit_kinds.each do |kind|
      without_selection = route_notification(kind: kind, subject: subjects.fetch(kind))
      assert_empty channels_for(without_selection, @chatbot), kind

      with_selection = route_notification(
        kind: kind,
        subject: subjects.fetch(kind),
        recipient_chatbot_ids: [ @chatbot.id ]
      )
      assert_equal %w[chatbot], channels_for(with_selection, @chatbot), kind
    end
  end

  test "a newly committed notification routes user and chatbot deliveries in the background" do
    notification = nil
    assert_enqueued_with(job: RouteNotificationDeliveriesWorker) do
      notification = create_notification
    end

    assert_nil notification.deliveries_generated_at

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    deliveries = notification.reload.notification_deliveries
    assert_not_nil notification.deliveries_generated_at
    assert_equal %w[chatbot email in_app], deliveries.order(:channel).pluck(:channel)
    assert_equal [ @author.id ], deliveries.where(channel: %w[email in_app]).distinct.pluck(:recipient_id)
    assert_equal [ @chatbot.id ], deliveries.where(channel: "chatbot").pluck(:recipient_id)
    assert_equal "delivered", deliveries.find_by!(channel: "in_app").status
    assert_equal %w[pending pending], deliveries.where.not(channel: "in_app").pluck(:status)
  end

  test "router retries preserve one delivery identity" do
    notification = create_notification
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_no_difference "NotificationDelivery.count" do
      RouteNotificationDeliveriesWorker.perform_now(notification.id)
    end
  end

  test "an outcome review email renders once and completes delivery" do
    notification = create_notification
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
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
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
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

  test "the global creator requires a persisted occurrence identity" do
    assert_raises(ArgumentError) do
      NotificationService.create!(
        kind: "outcome_review_due",
        subject: Outcome.new,
        actor: @author
      )
    end
  end

  test "the shared creator snapshots selected recipients for its router" do
    notification = NotificationService.create!(
      kind: "outcome_review_due",
      subject: @outcome,
      actor: @author,
      recipient_user_ids: [ @author.id, @author.id ],
      recipient_chatbot_ids: [ @chatbot.id ],
      recipient_audience: "group-#{@outcome.group_id}"
    )

    assert_equal [ @author.id ], notification.recipient_user_ids
    assert_equal [ @chatbot.id ], notification.recipient_chatbot_ids
    assert_equal "group-#{@outcome.group_id}", notification.recipient_audience
  end

  test "discussion announcements use the shared creator with selected recipients" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :normal, push: :quiet)

    notification = NotificationService.create!(
      kind: "discussion_announced",
      subject: discussion,
      actor: @author,
      recipient_user_ids: [ recipient.id ],
      recipient_chatbot_ids: [ @chatbot.id ],
      recipient_message: "Please review this thread"
    )
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

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
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

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

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal [ @chatbot.id ], notification.recipient_chatbot_ids
    assert_equal "Please review this discussion", notification.recipient_message
    assert_equal 1, Notification.where(kind: "new_discussion", subject: topic_item).count
    assert_equal %w[chatbot email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "a loud selected discussion recipient receives the direct path for both channels" do
    recipient = users(:member)
    recipient.memberships.find_by!(group: groups(:group)).update!(volume_email: :loud, volume_push: :loud)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/loud-discussion-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
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

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)
    normalize_other_subscribers(discussion.topic, recipient)
    assert_enqueued_emails 0 do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
    assert_enqueued_jobs 0, only: DeliverSubscriberPushTopicItemWorker do
      PublishSubscriberPushTopicItemWorker.perform_now(topic_item.id)
    end
  end

  test "a loud discussion announcement owns both external channels" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :loud, push: :loud)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/loud-announcement-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    normalize_other_subscribers(discussion.topic, recipient)
    topic_item = discussion.created_topic_item
    notification = route_notification(
      kind: "discussion_announced",
      subject: topic_item,
      recipient_user_ids: [ recipient.id ]
    )

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)
    assert_enqueued_emails 0 do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
    assert_enqueued_jobs 0, only: DeliverSubscriberPushTopicItemWorker do
      PublishSubscriberPushTopicItemWorker.perform_now(topic_item.id)
    end
  end

  test "a loud selected discussion edit recipient receives the direct path for both channels" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :loud, push: :loud)
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/loud-discussion-edit-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    topic_item = DiscussionService.update(
      discussion: discussion,
      actor: @author,
      params: {
        recipient_user_ids: [ recipient.id ],
        recipient_message: "Please review this edit"
      }
    )
    notification = Notification.find_by!(kind: "discussion_edited", subject: topic_item)

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal %w[email in_app], channels_for(notification, recipient)
    assert_equal [ "push" ], channels_for(notification, subscription)
    normalize_other_subscribers(discussion.topic, recipient)
    assert_enqueued_emails 0 do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
    assert_enqueued_jobs 0, only: DeliverSubscriberPushTopicItemWorker do
      PublishSubscriberPushTopicItemWorker.perform_now(topic_item.id)
    end
  end

  test "poll closing soon routes voter channels with recipient-localized values" do
    normal_user = users(:member)
    @poll.update!(notify_on_closing_soon: "voters")
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(email: :quiet, push: :quiet)
    TopicReader.for(user: normal_user, topic: @poll.topic).set_volume!(email: :normal, push: :quiet)
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
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

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
    TopicReader.for(user: @author, topic: @poll.topic).set_volume!(email: :quiet, push: :quiet)
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot.update!(event_kinds: @chatbot.event_kinds + [ "poll_expired" ])
    end
    @poll.update_column(:closed_at, Time.current)

    notification = NotificationService.create!(
      kind: "poll_expired",
      subject: @poll,
      actor: @poll.author
    )
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

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

  def route_notification(kind:, subject:, actor: @author, recipient_user_ids: [],
                         recipient_chatbot_ids: [], recipient_message: nil, recipient_context: {})
    notification = Notification.create!(
      kind: kind,
      subject: subject,
      actor: actor,
      recipient_user_ids: recipient_user_ids,
      recipient_chatbot_ids: recipient_chatbot_ids,
      recipient_message: recipient_message,
      recipient_context: recipient_context
    )
    NotificationDeliveryRouter.for(notification).route!
    notification
  end

  def channels_for(notification, recipient)
    notification.notification_deliveries
                .where(recipient: recipient)
                .order(:channel)
                .pluck(:channel)
  end

  def create_router_user(complaints_count: 0, deactivated_at: nil)
    token = SecureRandom.hex(5)
    User.create!(
      name: "Router #{token}",
      email: "router-#{token}@example.test",
      email_verified: true,
      complaints_count: complaints_count,
      deactivated_at: deactivated_at
    )
  end

  def normalize_other_subscribers(topic, recipient)
    topic.email_loud_members.or(topic.push_loud_members)
         .where.not(id: recipient.id).find_each do |other_recipient|
      TopicReader.for(user: other_recipient, topic: topic)
                 .set_volume!(email: :normal, push: :normal)
    end
  end

  def create_notification
    NotificationService.create!(
      kind: "outcome_review_due",
      subject: @outcome,
      actor: @outcome.author
    )
  end
end
