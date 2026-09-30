require 'test_helper'

class MessageChannelServiceTest < ActiveSupport::TestCase
  test "user-scoped serialization is not reused for shared channels" do
    topic = topics(:discussion_topic)
    user = users(:user)
    serialized_user_ids = []
    published_options = []

    serialize = lambda do |_models, serializer: nil, scope: {}, root: nil|
      serialized_user_ids << scope[:current_user_id]
      { records: [] }
    end
    publish = lambda do |_data, group_id: nil, user_id: nil, topic_id: nil|
      published_options << { group_id: group_id, user_id: user_id, topic_id: topic_id }
    end

    MessageChannelService.stub(:serialize_models, serialize) do
      MessageChannelService.stub(:publish_serialized_records, publish) do
        MessageChannelService.publish_models(
          [topic],
          scope: { current_user_id: user.id },
          group_id: topic.group_id,
          topic_id: topic.id,
          user_id: user.id
        )
      end
    end

    assert_equal [user.id, nil], serialized_user_ids
    assert_includes published_options, { group_id: nil, user_id: user.id, topic_id: nil }
    assert_includes published_options, { group_id: topic.group_id, user_id: nil, topic_id: topic.id }
  end

  test "topic models are serialized once for the group and every current guest" do
    discussion = discussions(:discussion)
    serialize_count = 0
    publications = []

    serialize = lambda do |_models, serializer: nil, scope: {}, root: nil|
      serialize_count += 1
      assert_nil scope[:current_user_id]
      { records: [] }
    end
    publish = lambda do |data, group_id: nil, user_id: nil, topic_id: nil|
      publications << { data: data, group_id: group_id, user_id: user_id }
    end

    MessageChannelService.stub(:serialize_models, serialize) do
      MessageChannelService.stub(:publish_serialized_records, publish) do
        MessageChannelService.publish_topic_model(discussion)
      end
    end

    assert_equal 1, serialize_count
    assert_equal 1, publications.map { |publication| publication[:data] }.uniq(&:object_id).length
    assert_equal [ discussion.group_id ], publications.filter_map { |publication| publication[:group_id] }

    guest_user_ids = publications.filter_map { |publication| publication[:user_id] }
    assert_equal discussion.topic.guests.pluck(:id).sort, guest_user_ids.sort
    assert_includes guest_user_ids, users(:guest_normal).id
    assert_not_includes guest_user_ids, users(:member_guest_loud).id
    assert_not_includes guest_user_ids, users(:former_guest_loud).id
    assert_not_includes guest_user_ids, users(:inactive_guest_loud).id
    assert_not_includes guest_user_ids, users(:non_guest_loud).id
  end

  test "direct topic models go only to guests, without user-specific fields" do
    discussion = discussions(:direct_discussion)
    publications = []

    publish = lambda do |data, group_id: nil, user_id: nil, topic_id: nil|
      publications << { data: data.as_json.deep_stringify_keys, group_id: group_id, user_id: user_id }
    end

    MessageChannelService.stub(:publish_serialized_records, publish) do
      MessageChannelService.publish_topic_model(discussion)
    end

    assert publications.none? { |publication| publication[:group_id] }
    assert_equal discussion.topic.guests.pluck(:id).sort, publications.map { |publication| publication[:user_id] }.sort

    topic_payload = publications.first[:data].fetch("topics").first
    assert_not topic_payload.key?("topic_reader_id")
    assert_not topic_payload.key?("last_read_at")
  end
end
