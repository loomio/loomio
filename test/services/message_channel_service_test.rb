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
end
