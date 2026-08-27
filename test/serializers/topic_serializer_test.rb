require "test_helper"

class TopicSerializerTest < ActiveSupport::TestCase
  test "reader defaults to normal volume when membership and topic reader are known missing" do
    topic = topics(:discussion_topic)
    user = users(:alien)
    cache = RecordCache.new
    cache.scope[:memberships_by_group_id] = { topic.group_id => nil }
    cache.scope[:topic_readers_by_topic_id] = { topic.id => nil }
    serializer = TopicSerializer.new(
      topic,
      scope: {
        cache: cache,
        current_user_id: user.id,
        exclude_types: []
      }
    )

    assert_equal "normal", serializer.reader.volume_email
  end
end
