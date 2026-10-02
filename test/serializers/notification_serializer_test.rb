require "test_helper"

class NotificationSerializerTest < ActiveSupport::TestCase
  test "timeline notifications identify their exact occurrence" do
    discussion = discussions(:discussion)
    edited_item = discussion.topic_items.create!(
      kind: "discussion_edited", topic: discussion.topic, user: users(:admin)
    )
    notification = create_notification(subject: edited_item)

    serialized = serialize(notification)

    assert_equal edited_item.topic_id, serialized[:topic_id]
    assert_equal edited_item.sequence_id, serialized[:sequence_id]
    refute_equal discussion.created_topic_item.sequence_id, serialized[:sequence_id]
  end

  test "direct notifications identify the subject's creation item including sequence zero" do
    discussion = discussions(:discussion)
    serialized = serialize(create_notification(subject: discussion))

    assert_equal discussion.topic_id, serialized[:topic_id]
    assert_equal 0, serialized[:sequence_id]
  end

  test "comment and reaction notifications identify the comment item" do
    comment = comments(:public_discussion_comment)
    item = topic_items(:public_discussion_comment_topic_item)
    reaction = Reaction.create!(reactable: comment, user: users(:user), reaction: "🙂")

    [comment, reaction].each do |subject|
      notification = create_notification(subject: subject)
      serialized = serialize(notification)

      assert_equal item.topic_id, serialized[:topic_id]
      assert_equal item.sequence_id, serialized[:sequence_id]
      assert_equal item, notification.read_topic_item
    end
  end

  test "notifications outside a thread have no read location" do
    serialized = serialize(create_notification(subject: groups(:group)))

    assert_nil serialized[:topic_id]
    assert_nil serialized[:sequence_id]
  end

  test "reaction read locations follow a comment moved to another thread" do
    comment = comments(:public_discussion_comment)
    item = topic_items(:public_discussion_comment_topic_item)
    reaction = Reaction.create!(reactable: comment, user: users(:user), reaction: "🙂")
    notification = create_notification(subject: reaction)
    destination = topics(:discussion_topic)

    MoveCommentsWorker.perform_now([item.id], item.topic_id, destination.id, users(:admin).id)

    serialized = serialize(notification.reload)
    assert_equal destination.id, serialized[:topic_id]
    assert_equal item.reload.sequence_id, serialized[:sequence_id]
  end

  test "read locations are batched for notification lists and live updates" do
    comment = comments(:public_discussion_comment)
    reaction = Reaction.create!(reactable: comment, user: users(:user), reaction: "🙂")
    notifications = [discussions(:discussion), comment, reaction, groups(:group),
                     topic_items(:discussion_created_topic_item)].flat_map do |subject|
      3.times.map { create_notification(subject: subject) }
    end
    expected_locations = notifications.to_h do |notification|
      item = notification.read_topic_item
      [notification.id, {topic_id: item&.topic_id, sequence_id: item&.sequence_id}]
    end
    notifications = Notification.where(id: notifications.map(&:id)).to_a
    item_queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _started, _finished, _id, payload|
      item_queries << payload[:sql] if payload[:sql].match?(/SELECT .* FROM "topic_items"/)
    end

    cache = RecordCache.for_collection(notifications, users(:user).id)
    assert_equal 2, item_queries.length, "load exact occurrences and creation items in two queries"
    assert_no_record_cache_fallbacks do
      notifications.each do |notification|
        serialized = serialize(notification, cache: cache)
        assert_equal expected_locations.fetch(notification.id), serialized.slice(:topic_id, :sequence_id)
      end
    end

    assert_equal 2, item_queries.length, "serialization must not query more topic items"
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  private

  def create_notification(subject:)
    Notification.create!(subject: subject, actor: users(:admin), kind: "discussion_edited")
  end

  def serialize(notification, **scope)
    NotificationSerializer.new(notification, scope: scope.merge(current_user_id: users(:user).id))
                          .as_json.fetch(:notification)
  end
end
