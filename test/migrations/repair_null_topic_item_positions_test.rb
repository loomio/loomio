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

  test "removes obsolete poll lifecycle items while preserving notifications" do
    user = users(:user)
    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      poll_option_names: [ "Agree", "Disagree" ],
      closing_at: 5.days.from_now,
      group_id: groups(:group).id
    }, actor: user)

    notifications = %w[poll_closing_soon poll_expired poll_option_added].map do |kind|
      topic_item = TopicItem.create!(kind: kind, itemable: poll, topic: poll.topic, user: user)
      Notification.create!(kind: kind, subject: topic_item, actor: user)
    end

    RepairNullTopicItemPositions.new.migrate(:up)

    assert_not TopicItem.exists?(kind: %w[poll_closing_soon poll_expired poll_option_added])
    notifications.each do |notification|
      notification.reload
      assert_equal "Poll", notification.subject_type
      assert_equal poll.id, notification.subject_id
    end
  end
end
