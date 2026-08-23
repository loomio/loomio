require "test_helper"

class NotificationDeliveryResolverTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  test "an outcome review email renders and completes without an topic_item" do
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

  test "an outcome review chatbot delivery renders and completes without an topic_item" do
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

  test "new discussions retain their timeline topic_item without using it for delivery" do
    recipient = users(:member)
    discussion = DiscussionService.create(
      params: {
        title: "Direct notification discussion",
        group_id: groups(:group).id,
        recipient_user_ids: [ recipient.id ],
        recipient_chatbot_ids: [ @chatbot.id ],
        recipient_message: "Please review this discussion"
      },
      actor: @author
    )
    topic_item = TopicItems::NewDiscussion.find(discussion.created_topic_item.id)
    notification = Notification.find_by!(
      kind: "new_discussion",
      subject: discussion
    )

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal [ @chatbot.id ], notification.recipient_chatbot_ids
    assert_equal "Please review this discussion", notification.recipient_message
    assert_equal 1, Notification.where(kind: "new_discussion", subject: discussion).count
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
    notification = Notification.find_by!(kind: "new_discussion", subject: discussion)

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_includes topic_item.subscribed_recipients, recipient
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

  def create_notification
    NotificationService.create!(
      kind: "outcome_review_due",
      subject: @outcome,
      actor: @outcome.author
    )
  end
end
