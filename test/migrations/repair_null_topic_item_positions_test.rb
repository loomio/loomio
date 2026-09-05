require "test_helper"
require Rails.root.join("db/migrate/20260831000001_repair_null_topic_item_positions")

class RepairNullTopicItemPositionsTest < ActiveSupport::TestCase
  test "preserves descendants of obsolete items and repairs their positions" do
    poll = PollService.create(params: {
      title: "Legacy lifecycle", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now, group_id: groups(:group).id
    }, actor: users(:admin))
    obsolete = TopicItem.create!(kind: "poll_expired", itemable: poll, topic: poll.topic, user: users(:admin))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: "Published response"), actor: users(:admin))
    child = comment.created_topic_item
    child.update_columns(parent_id: obsolete.id, depth: obsolete.depth + 1)

    2.times { RepairNullTopicItemPositions.new.migrate(:up) }
    CleanupService.delete_orphan_records

    assert Comment.exists?(comment.id)
    assert TopicItem.exists?(child.id)
    assert_not TopicItem.exists?(obsolete.id)
    assert_nothing_raised { TopicService.verify_integrity!(poll.topic_id) }
  end

  test "failed repair rolls back obsolete-item deletion" do
    poll = PollService.create(params: {
      title: "Legacy rollback", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now, group_id: groups(:group).id
    }, actor: users(:admin))
    obsolete = TopicItem.create!(kind: "poll_expired", itemable: poll, topic: poll.topic, user: users(:admin))
    notification = Notification.create!(kind: "poll_expired", subject: obsolete, actor: users(:admin))

    TopicService.stub(:repair, ->(*) { raise "repair failed" }) do
      assert_raises(RuntimeError) { RepairNullTopicItemPositions.new.migrate(:up) }
    end

    assert TopicItem.exists?(obsolete.id)
    assert_equal "TopicItem", notification.reload.subject_type
    assert_equal obsolete.id, notification.subject_id
  end

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
