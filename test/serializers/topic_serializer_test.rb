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

  test "personal group and direct topic payloads use the viewers reader and channel preferences" do
    freeze_time do
      viewer = users(:guest_quiet)
      %i[discussion_topic direct_topic].each do |fixture|
        topic = topics(fixture)
        reader = TopicReader.find_by!(topic: topic, user: viewer)
        reader.update!(read_ranges: [[0, 0]], last_read_at: 1.hour.ago, dismissed_at: 2.hours.ago)
        TopicReader.find_by!(topic: topic, user: users(:guest_normal)).update!(read_ranges: [[5, 8]])
        cache = RecordCache.for_collection([topic], viewer.id)
        serializer = TopicSerializer.new(topic, scope: { cache: cache, current_user_id: viewer.id, exclude_types: [] })
        payload = JSON.parse(serializer.to_json, symbolize_names: true).fetch(:topic)

        assert_equal reader.id, payload.fetch(:topic_reader_id)
        assert_equal "quiet", payload.fetch(:reader_volume_email)
        assert_equal "loud", payload.fetch(:reader_volume_push)
        assert_equal [[0, 0]], payload.fetch(:read_ranges)
        assert_equal 1.hour.ago, Time.iso8601(payload.fetch(:last_read_at))
        assert_equal 2.hours.ago, Time.iso8601(payload.fetch(:dismissed_at))
        assert_equal users(:member_normal).id, payload.fetch(:reader_inviter_id)
        assert_equal true, payload.fetch(:reader_guest)
        assert_equal false, payload.fetch(:reader_admin)
      end
    end
  end

  test "shared topic payloads omit each viewers private reader state" do
    %i[discussion_topic direct_topic].each do |fixture|
      topic = topics(fixture)
      cache = RecordCache.for_collection([topic], nil)
      serializer = TopicSerializer.new(topic, scope: {cache: cache, current_user_id: nil, exclude_types: []})
      payload = JSON.parse(serializer.to_json, symbolize_names: true).fetch(:topic)

      %i[topic_reader_id reader_volume_email reader_volume_push last_read_at dismissed_at read_ranges reader_inviter_id reader_guest reader_admin].each do |field|
        refute payload.key?(field), "#{fixture}: #{field}"
      end
    end
  end
end
