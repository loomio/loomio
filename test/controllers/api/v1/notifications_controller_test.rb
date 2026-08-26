require 'test_helper'

class Api::V1::NotificationsControllerTest < ActionController::TestCase
  setup do
    @user  = users(:user)
    @admin = users(:admin)
  end

  test "index returns notifications for accessible topics" do
    notification = create_notification(user: @user, actor: @admin, subject: discussions(:discussion))
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_includes ids, notification.id
  end

  test "index excludes notifications whose topic is not accessible" do
    notification = create_notification(user: @user, actor: users(:alien), subject: discussions(:alien_discussion))
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_not_includes ids, notification.id
  end

  test "index excludes notifications for discarded comments" do
    comment = comments(:public_discussion_comment)
    notification = create_notification(user: @user, actor: @admin, subject: comment)
    comment.update!(discarded_at: Time.current)
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_not_includes ids, notification.id
  end

  test "index exposes a global notification only through the current user's in-app delivery" do
    subject = topic_items(:discussion_created_topic_item).itemable
    notification = Notification.create!(
      actor: @admin,
      kind: "discussion_edited",
      subject: subject
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current,
      translation_values: { title: "Recipient-specific title" }
    )

    sign_in @admin
    get :index
    admin_ids = JSON.parse(response.body)["notifications"].map { |record| record["id"] }
    assert_not_includes admin_ids, notification.id

    sign_in @user
    get :index

    assert_response :success
    ids = JSON.parse(response.body)["notifications"].map { |record| record["id"] }
    assert_includes ids, notification.id
    serialized = JSON.parse(response.body)["notifications"].find { |record| record["id"] == notification.id }
    assert_equal "Recipient-specific title", serialized["title"]
  end

  test "viewed updates only the current user's global in-app delivery" do
    subject = topic_items(:discussion_created_topic_item).itemable
    notification = Notification.create!(
      actor: @admin,
      kind: "discussion_edited",
      subject: subject
    )
    user_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )
    admin_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @admin,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    sign_in @user
    post :viewed

    assert_response :success
    assert_not_nil user_delivery.reload.viewed_at
    assert_nil admin_delivery.reload.viewed_at
  end

  test "index excludes pending and inaccessible global deliveries" do
    inaccessible_subject = topic_items(:alien_discussion_created_topic_item).itemable
    inaccessible_notification = Notification.create!(
      actor: users(:alien),
      kind: "discussion_edited",
      subject: inaccessible_subject
    )
    NotificationDelivery.create!(
      notification: inaccessible_notification,
      recipient: @user,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    accessible_subject = topic_items(:discussion_created_topic_item).itemable
    pending_notification = Notification.create!(
      actor: @admin,
      kind: "discussion_edited",
      subject: accessible_subject
    )
    NotificationDelivery.create!(
      notification: pending_notification,
      recipient: @user,
      channel: "in_app",
      status: "pending"
    )

    sign_in @user
    get :index

    assert_response :success
    ids = JSON.parse(response.body)["notifications"].map { |record| record["id"] }
    assert_not_includes ids, inaccessible_notification.id
    assert_not_includes ids, pending_notification.id
  end

  private

  def create_notification(user:, actor:, subject:)
    notification = Notification.create!(
      actor: actor,
      kind: "discussion_edited",
      subject: subject
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: user,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )
    notification
  end
end
