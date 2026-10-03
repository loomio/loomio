require "test_helper"

# Exercise the real edit endpoint and notification router. External email uses
# Rails' test delivery adapter; no network delivery is performed.
class Api::V1::DiscussionEditChangeNoteTest < ActionController::TestCase
  tests Api::V1::DiscussionsController

  setup do
    @actor = users(:admin)
    @discussion = topics(:discussion_topic).topicable
    @note = "Explained the revised discussion scope 74193"
    sign_in @actor
  end

  test "discussion edit preserves whats changed on its notification occurrence" do
    edit_discussion(recipient_message: @note)

    notification = edit_notification
    assert_equal @note, notification.reload.recipient_message
    assert_equal "TopicItem", notification.subject_type
    assert_equal "discussion_edited", notification.subject.kind
    assert_equal @discussion.topic_id, notification.subject.topic_id
    assert_equal @actor.id, notification.actor_id
    assert_enqueued_with(job: RouteNotificationDeliveriesWorker, args: [notification.id])
  end

  test "discussion edit saves whats changed without changing the discussion content" do
    title_before = @discussion.title
    put :update, params: { id: @discussion.id, discussion: { recipient_message: @note } }, format: :json

    assert_response :success
    assert_equal title_before, @discussion.reload.title
    assert_equal @note, edit_notification.reload.recipient_message
  end

  test "discussion edit response retains whats changed for the thread client" do
    edit_discussion(recipient_message: @note)

    # Storage succeeds, so a missing response note pinpoints the read boundary.
    assert_equal @note, edit_notification.reload.recipient_message
    assert response.parsed_body.to_json.include?(@note), "The saved What's changed note is missing from the discussion edit response"
  end

  test "discussion edit with empty notify selection has no directed deliveries" do
    edit_discussion(recipient_message: @note)
    notification = edit_notification

    assert_empty notification.recipient_user_ids
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_empty notification.notification_deliveries
    assert_no_enqueued_jobs only: DeliverNotificationEmailWorker
    # All-activity subscribers use a separate path, even with no Notify selection.
    assert_enqueued_with(job: PublishSubscriberEmailsTopicItemWorker, args: [notification.subject_id])
  end

  test "discussion edit with neither note nor notify selection creates no edit notification" do
    assert_no_difference ["Notification.where(kind: 'discussion_edited').count", "TopicItem.where(kind: 'discussion_edited').count"] do
      edit_discussion
    end
    assert_no_enqueued_jobs only: RouteNotificationDeliveriesWorker
  end

  test "discussion notify selection routes eligible members excludes actor and respects quiet email" do
    normal = users(:member_normal)
    quiet = users(:member_quiet)
    edit_discussion(recipient_message: @note, recipient_user_ids: [normal.id, quiet.id, @actor.id])
    notification = edit_notification

    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal [normal.id, quiet.id].sort,
      notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id).sort
    assert_equal [normal.id], notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
    assert_not notification.notification_deliveries.where(recipient: @actor).exists?
    assert_not notification.notification_deliveries.where(recipient: users(:alien)).exists?
    email_delivery = notification.notification_deliveries.find_by!(channel: "email", recipient: normal)
    assert_enqueued_with(job: DeliverNotificationEmailWorker, args: [email_delivery.id])

    DeliverNotificationEmailWorker.perform_now(email_delivery.id)
    assert_equal [normal.email], ActionMailer::Base.deliveries.last.to
    assert_includes ActionMailer::Base.deliveries.last.html_part.body.to_s, @note
    assert email_delivery.reload.delivered_at
  end

  test "discussion notify selection works without a whats changed note" do
    recipient = users(:member_normal)
    edit_discussion(recipient_user_ids: [recipient.id])
    notification = Notification.find_by!(kind: "discussion_edited", subject: @discussion)

    assert_nil notification.recipient_message
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal [recipient.id], notification.notification_deliveries.pluck(:recipient_id).uniq
  end

  test "discussion notify email selection invites a new guest and routes the notification" do
    email = "discussion-edit-guest@example.test"
    assert_not User.exists?(email: email)
    edit_discussion(recipient_message: @note, recipient_emails: [email])
    recipient = User.find_by!(email: email)
    notification = edit_notification

    assert @discussion.topic.members.exists?(recipient.id)
    assert_includes notification.recipient_user_ids, recipient.id
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal [recipient.id], notification.notification_deliveries.pluck(:recipient_id).uniq
  end

  test "discussion group notify audience expands to members without actor or unrelated group" do
    edit_discussion(recipient_message: @note, recipient_audience: "group-#{@discussion.group_id}")
    notification = edit_notification

    assert_equal "group-#{@discussion.group_id}", notification.recipient_audience
    assert_includes notification.recipient_user_ids, users(:member_normal).id
    assert_not_includes notification.recipient_user_ids, users(:alien).id
    assert_not_includes notification.recipient_user_ids, @actor.id
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_includes notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id), users(:member_normal).id
    assert_not notification.notification_deliveries.where(recipient: @actor).exists?
  end

  test "direct discussion notify selection reaches its existing guest" do
    @discussion = topics(:direct_topic).topicable
    @actor = @discussion.author
    sign_in @actor
    recipient = users(:guest_quiet)

    edit_discussion(recipient_message: @note, recipient_user_ids: [recipient.id])
    notification = edit_notification
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [recipient.id], notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
    assert_empty notification.notification_deliveries.where(channel: "email")
    assert_equal @note, notification.recipient_message
  end

  private

  def edit_discussion(**attributes)
    put :update, params: {
      id: @discussion.id,
      discussion: {
        title: "Updated discussion scope",
        recipient_user_ids: [],
        recipient_emails: [],
        recipient_chatbot_ids: [],
        recipient_audience: nil,
        **attributes
      }
    }, format: :json
    assert_response :success
    assert_equal "Updated discussion scope", @discussion.reload.title
  end

  def edit_notification
    item = TopicItem.find_by!(kind: "discussion_edited", itemable: @discussion)
    Notification.find_by!(kind: "discussion_edited", subject: item)
  end
end

class Api::V1::DiscussionEditChangeNoteReadbackTest < ActionController::TestCase
  tests Api::V1::TopicItemsController

  test "discussion thread reload retains the saved whats changed note" do
    actor = users(:admin)
    discussion = topics(:discussion_topic).topicable
    note = "Explained the persisted discussion edit 28641"
    item = nil
    DiscussionService.update(
      discussion: discussion,
      actor: actor,
      params: { title: "Revised discussion", recipient_message: note }
    ) { |topic_item| item = topic_item }
    assert_equal note, Notification.find_by!(subject: item, kind: "discussion_edited").reload.recipient_message
    sign_in actor

    get :index, params: { topic_id: discussion.topic_id }, format: :json

    assert_response :success
    assert_includes response.parsed_body.fetch("topic_items").map { |record| record.fetch("id") }, item.id
    assert response.parsed_body.to_json.include?(note), "The saved What's changed note is missing after reloading the discussion thread"
  end
end
