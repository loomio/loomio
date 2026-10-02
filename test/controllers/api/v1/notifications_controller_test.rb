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

  test "index returns topic item notifications" do
    notifications = [
      topic_items(:discussion_created_topic_item),
      topic_items(:public_discussion_comment_topic_item)
    ].map do |subject|
      create_notification(user: @user, actor: @admin, subject: subject)
    end
    sign_in @user

    get :index

    assert_response :success
    ids = JSON.parse(response.body)["notifications"].pluck("id")
    notifications.each { |notification| assert_includes ids, notification.id }
  end

  test "index includes read locations for comment reactions" do
    comment = comments(:public_discussion_comment)
    reaction = Reaction.create!(reactable: comment, user: @admin, reaction: "🙂")
    notification = create_notification(user: @user, actor: @admin, subject: reaction)
    sign_in @user

    assert_no_record_cache_fallbacks { get :index }

    assert_response :success
    serialized = JSON.parse(response.body)["notifications"].find { |record| record["id"] == notification.id }
    assert_equal comment.created_topic_item.topic_id, serialized["topic_id"]
    assert_equal comment.created_topic_item.sequence_id, serialized["sequence_id"]
    assert_equal false, serialized["viewed"]
  end

  test "reaction read locations respect the group and direct topic access matrix" do
    [:discussion_topic, :direct_topic].each do |fixture|
      topic = topics(fixture)
      topic.topicable.create_missing_created_topic_item! unless topic.topicable.created_topic_item
      comment = CommentService.create(
        comment: Comment.new(parent: topic.topicable, body: "Read location access matrix"),
        actor: users(:guest_normal)
      )
      reaction = Reaction.create!(reactable: comment, user: @admin, reaction: "🙂")

      {guest_normal: true, former_guest_loud: false, non_guest_loud: false}.each do |role, accessible|
        recipient = users(role)
        notification = create_notification(user: recipient, actor: @admin, subject: reaction)
        sign_in recipient

        get :index

        assert_response :success
        serialized = JSON.parse(response.body)["notifications"].find { |record| record["id"] == notification.id }
        if accessible
          assert_equal topic.id, serialized.fetch("topic_id")
          assert_equal comment.created_topic_item.sequence_id, serialized.fetch("sequence_id")
        else
          assert_nil serialized, "#{role} must not receive #{fixture} reaction read locations"
        end
      end
    end
  end

  test "index preloads direct notification topic paths" do
    discussion = discussions(:discussion)
    poll = PollService.create(params: {
      title: "Notification preload poll",
      poll_type: "poll",
      group_id: groups(:group).id,
      closing_at: 5.days.from_now,
      poll_option_names: [ "Agree", "Disagree" ]
    }, actor: @admin)
    comment = comments(:public_discussion_comment)
    [ discussion, discussions(:public_discussion), poll, comment ].each do |subject|
      3.times { create_notification(user: @user, actor: @admin, subject: subject) }
    end

    record_query_counts = Hash.new(0)
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _started, _finished, _id, payload|
      sql = payload[:sql].to_s
      if match = sql.match(/SELECT "(topics|groups|discussions|polls|comments)"\.\*/)
        record_query_counts[match[1]] += 1
      end
    end

    sign_in @user
    get :index

    assert_response :success
    assert record_query_counts.values.all? { |count| count <= 4 }, record_query_counts.inspect
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
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

  test "index batches poll visibility checks without weakening topic access" do
    accessible_polls = 2.times.map do |index|
      PollService.create(params: {
        title: "Accessible notification poll #{index}",
        poll_type: "poll",
        group_id: groups(:group).id,
        closing_at: 5.days.from_now,
        poll_option_names: [ "Agree", "Disagree" ]
      }, actor: @admin)
    end
    accessible_notifications = accessible_polls.map do |poll|
      create_notification(user: @user, actor: @admin, subject: poll.created_topic_item)
    end
    discarded_poll = PollService.create(params: {
      title: "Discarded notification poll",
      poll_type: "poll",
      group_id: groups(:group).id,
      closing_at: 5.days.from_now,
      poll_option_names: [ "Agree", "Disagree" ]
    }, actor: @admin)
    discarded_notification = create_notification(
      user: @user,
      actor: @admin,
      subject: discarded_poll.created_topic_item
    )
    discarded_poll.update!(discarded_at: Time.current)

    private_group = Group.create!(name: "Private notification group", group_privacy: "closed")
    private_group.add_admin!(users(:alien))
    inaccessible_poll = PollService.create(params: {
      title: "Inaccessible notification poll",
      poll_type: "poll",
      private: true,
      group_id: private_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: [ "Agree", "Disagree" ]
    }, actor: users(:alien))
    inaccessible_notification = create_notification(
      user: @user,
      actor: users(:alien),
      subject: inaccessible_poll.created_topic_item
    )

    poll_visibility_queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _started, _finished, _id, payload|
      sql = payload[:sql].to_s
      poll_visibility_queries << sql if sql.include?('LEFT OUTER JOIN topics t ON t.id = polls.topic_id')
    end

    sign_in @user
    get :index
    ActiveSupport::Notifications.unsubscribe(subscriber)

    assert_response :success
    ids = JSON.parse(response.body)["notifications"].map { |record| record["id"] }
    accessible_notifications.each { |notification| assert_includes ids, notification.id }
    assert_not_includes ids, inaccessible_notification.id
    assert_not_includes ids, discarded_notification.id
    assert_equal 1, poll_visibility_queries.length
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
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
      delivered_at: Time.current
    )
    admin_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @admin,
      channel: "in_app",
      delivered_at: Time.current
    )

    sign_in @user
    post :viewed

    assert_response :success
    assert_not_nil user_delivery.reload.viewed_at
    assert_nil admin_delivery.reload.viewed_at
  end

  test "index excludes undelivered and inaccessible global deliveries" do
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
      delivered_at: Time.current
    )

    accessible_subject = topic_items(:discussion_created_topic_item).itemable
    undelivered_notification = Notification.create!(
      actor: @admin,
      kind: "discussion_edited",
      subject: accessible_subject
    )
    undelivered_delivery = NotificationDelivery.create!(
      notification: undelivered_notification,
      recipient: @user,
      channel: "in_app"
    )
    assert_nil undelivered_delivery.delivered_at

    sign_in @user
    get :index

    assert_response :success
    ids = JSON.parse(response.body)["notifications"].map { |record| record["id"] }
    assert_not_includes ids, inaccessible_notification.id
    assert_not_includes ids, undelivered_notification.id
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
      delivered_at: Time.current
    )
    notification
  end
end
