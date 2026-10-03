require "test_helper"

class Api::V1::PollEditChangeNoteTest < ActionController::TestCase
  tests Api::V1::PollsController

  setup do
    @actor = users(:admin)
    @recipient = users(:member_normal)
    @quiet_recipient = users(:member_quiet)
    @group = groups(:group)
    @note = "Poll edit summary regression marker"
    @poll = PollService.create(
      params: {
        title: "Standalone poll before editing",
        poll_type: "proposal",
        group_id: @group.id,
        poll_option_names: %w[agree disagree],
        closing_at: 3.days.from_now,
        notify_on_open: false
      },
      actor: @actor
    )
    TopicReader.for(user: @recipient, topic: @poll.topic).set_volume!(email: :normal, push: :quiet)
    TopicReader.for(user: @quiet_recipient, topic: @poll.topic).set_volume!(email: :quiet, push: :quiet)
    sign_in @actor
    clear_enqueued_jobs
  end

  test "poll edit accepts and stores the whats changed note without selected recipients" do
    edit_poll(recipient_message: @note)

    assert_equal "Standalone poll after editing", @poll.reload.title
    assert_equal @note, edit_notification.reload.recipient_message
    assert_empty edit_notification.recipient_user_ids
    assert_equal "poll_edited", edit_notification.subject.kind
    assert_equal @poll.topic_id, edit_notification.subject.topic_id
  end

  test "poll edit response preserves the whats changed note for the thread" do
    edit_poll(recipient_message: @note)

    assert_equal @note, edit_notification.reload.recipient_message
    assert JSON.parse(response.body).fetch("topic_items").any? { |item| item["kind"] == "poll_edited" }
    assert response.body.include?(@note), "The saved What's changed note is missing from the poll edit response"
  end

  test "poll edit saves a whats changed note without changing poll content" do
    title_before = @poll.title
    patch :update, params: {
      id: @poll.id,
      poll: { recipient_message: @note, recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: [] }
    }

    assert_response :success
    assert_equal title_before, @poll.reload.title
    assert_equal @note, edit_notification.reload.recipient_message
  end

  test "poll edit notify selection routes selected members and respects channel preferences" do
    assert_enqueued_with(job: RouteNotificationDeliveriesWorker) do
      edit_poll(recipient_message: @note, recipient_user_ids: [@actor.id, @recipient.id, @quiet_recipient.id])
    end
    notification = edit_notification
    assert_equal [@actor.id, @recipient.id, @quiet_recipient.id].sort, notification.recipient_user_ids.sort
    clear_enqueued_jobs

    assert_enqueued_jobs 1, only: DeliverNotificationEmailWorker do
      RouteNotificationDeliveriesWorker.perform_now(notification.id)
    end

    deliveries = notification.notification_deliveries
    assert_equal [@recipient.id, @quiet_recipient.id].sort,
                 deliveries.where(channel: "in_app").pluck(:recipient_id).sort
    assert_equal [@recipient.id], deliveries.where(channel: "email").pluck(:recipient_id)
    assert_empty deliveries.where(channel: "push")
    assert_not deliveries.exists?(recipient: @actor)
    assert_not deliveries.exists?(recipient: users(:alien))

    email_delivery = deliveries.find_by!(channel: "email", recipient: @recipient)
    assert_enqueued_with(job: DeliverNotificationEmailWorker, args: [email_delivery.id])
    mail = NotificationMailer.notification(email_delivery.id)
    assert_equal [@recipient.email], mail.to
    html = Nokogiri::HTML5(mail.html_part&.body&.decoded || mail.body.decoded)
    assert_includes html.text, @note
    assert_empty ActionMailer::Base.deliveries, "Rendering and queue assertions must not send real emails"
  end

  test "poll edit with no notify selection creates no direct deliveries" do
    edit_poll(recipient_message: @note)
    notification = edit_notification
    assert_empty notification.recipient_user_ids
    clear_enqueued_jobs

    assert_no_enqueued_jobs only: DeliverNotificationEmailWorker do
      RouteNotificationDeliveriesWorker.perform_now(notification.id)
    end
    assert_empty notification.notification_deliveries
    # All-activity subscribers have a separate publication path; an empty
    # Notify selector only means no explicitly selected notification recipients.
  end

  test "poll edit notify selection works without a whats changed note" do
    assert_no_difference "TopicItem.where(kind: 'poll_edited').count" do
      edit_poll(recipient_user_ids: [@recipient.id])
    end
    notification = edit_notification
    assert_equal @poll, notification.subject
    assert_nil notification.recipient_message

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal [@recipient.id], notification.notification_deliveries.distinct.pluck(:recipient_id)
  end

  test "poll edit with neither a note nor notify selection creates no edit notification" do
    assert_no_difference "Notification.where(kind: 'poll_edited').count" do
      edit_poll
    end

    assert_equal "Standalone poll after editing", @poll.reload.title
  end

  test "poll edit notify group audience selects active members other than the actor" do
    edit_poll(recipient_message: @note, recipient_audience: "group-#{@group.id}")
    notification = edit_notification
    expected_ids = @group.members.active.humans.where.not(id: @actor.id).pluck(:id).sort
    assert_equal "group-#{@group.id}", notification.recipient_audience
    assert_equal expected_ids, notification.recipient_user_ids.sort

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal expected_ids, notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id).sort
    assert_not notification.notification_deliveries.exists?(recipient: @actor)
    assert_not notification.notification_deliveries.exists?(recipient: users(:alien))
    assert_not notification.notification_deliveries.exists?(recipient: users(:inactive_member_loud))
  end

  test "poll edit routing excludes a selected member whose access is revoked before delivery" do
    edit_poll(recipient_message: @note, recipient_user_ids: [@recipient.id])
    notification = edit_notification
    memberships(:member_normal_membership).update!(revoked_at: Time.current)
    assert_not @poll.topic.members.exists?(@recipient.id)

    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_empty notification.notification_deliveries
  end


  private

  def edit_poll(**attributes)
    patch :update, params: {
      id: @poll.id,
      poll: {
        title: "Standalone poll after editing",
        recipient_user_ids: [],
        recipient_emails: [],
        recipient_chatbot_ids: []
      }.merge(attributes)
    }
    assert_response :success
  end

  def edit_notification
    Notification.about(@poll).find_by!(kind: "poll_edited")
  end
end

class Api::V1::PollEditChangeNoteHistoryTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  test "reloading a standalone poll thread preserves the whats changed note" do
    actor = users(:admin)
    poll = PollService.create(
      params: {
        title: "Standalone poll history",
        poll_type: "proposal",
        group_id: groups(:group).id,
        poll_option_names: %w[agree disagree],
        closing_at: 3.days.from_now,
        notify_on_open: false
      },
      actor: actor
    )
    note = "Persisted poll history note regression marker"
    PollService.update(poll: poll, params: { recipient_message: note }, actor: actor)
    assert_equal note, Notification.about(poll).find_by!(kind: "poll_edited").reload.recipient_message
    sign_in users(:member)

    get :index, params: { poll_id: poll.id, kind: "poll_edited" }

    assert_response :success
    items = JSON.parse(response.body).fetch("topic_items")
    assert_equal ["poll_edited"], items.pluck("kind")
    assert response.body.include?(note), "The saved What's changed note is missing after reloading the poll thread"
  end
end
