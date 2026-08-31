require "test_helper"
require Rails.root.join("db/migrate/20260831000001_repair_null_topic_item_positions")

class RepairNullTopicItemPositionsTest < ActiveSupport::TestCase
  test "repairs every position in a topic containing a null position key" do
    topic = discussions(:public_discussion).topic
    topic_item = TopicItem.where(topic: topic).where.not(parent_id: nil).first!
    topic_item.update_columns(position: 0, position_key: nil)

    RepairNullTopicItemPositions.new.migrate(:up)

    assert TopicItem.where(topic: topic, position_key: nil).none?
    assert_nothing_raised { TopicService.verify_integrity!(topic.id) }
  end
end
