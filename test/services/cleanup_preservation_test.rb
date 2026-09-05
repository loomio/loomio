require "test_helper"

class CleanupPreservationTest < ActiveSupport::TestCase
  test "a comment remains available when only its replies identify the surviving topic" do
    parent = CommentService.create(comment: Comment.new(parent: discussions(:discussion), body: "Original context"), actor: users(:admin))
    reply = CommentService.create(comment: Comment.new(parent: parent, body: "Published reply"), actor: users(:admin))
    reply.topic_items.update_all(parent_id: parent.topic.topicable.created_topic_item.id, depth: 1)
    parent.topic_items.delete_all
    parent.update_column(:parent_id, Discussion.maximum(:id) + 1000)

    2.times { CleanupService.delete_orphan_records }

    assert Comment.exists?(parent.id)
    assert Comment.exists?(reply.id)
    assert reply.topic_items.exists?
  end

  test "a missing comment timeline does not destroy its published replies" do
    parent = CommentService.create(comment: Comment.new(parent: discussions(:discussion), body: "Original comment"), actor: users(:admin))
    reply = CommentService.create(comment: Comment.new(parent: parent, body: "Published reply"), actor: users(:admin))
    reply.topic_items.update_all(parent_id: parent.topic.topicable.created_topic_item.id, depth: 1)
    parent.topic_items.delete_all

    2.times { CleanupService.delete_orphan_records }

    assert Comment.exists?(parent.id)
    assert Comment.exists?(reply.id)
    assert reply.topic_items.exists?
  end

  test "dangling timeline ancestors cannot cascade-delete live descendants" do
    discussion = discussions(:discussion)
    comment = CommentService.create(comment: Comment.new(parent: discussion, body: "Published reply"), actor: users(:admin))
    dangling = TopicItem.create!(kind: "discussion_edited", itemable: discussion, topic: discussion.topic, user: users(:admin))
    dangling.update_column(:itemable_id, Discussion.maximum(:id) + 1000)
    child = comment.created_topic_item
    child.update_columns(parent_id: dangling.id, depth: dangling.depth + 1)

    2.times { CleanupService.delete_orphan_records }

    assert Comment.exists?(comment.id)
    assert TopicItem.exists?(child.id)
    assert TopicItem.exists?(dangling.id), "damaged ancestors remain available for explicit repair"
  end

  test "a missing parent group does not make a populated private subgroup disposable" do
    actor = users(:admin)
    root = Group.create!(name: "Missing parent", creator: actor, group_privacy: "secret")
    subgroup = Group.create!(name: "Working subgroup", creator: actor, parent: root, group_privacy: "secret")
    membership = subgroup.add_admin!(actor)
    discussion = DiscussionService.create(params: { group_id: subgroup.id, title: "Actual work" }, actor: actor)
    Group.where(id: root.id).delete_all

    2.times { CleanupService.delete_orphan_records }

    assert Group.exists?(subgroup.id)
    assert Discussion.exists?(discussion.id)
    assert Membership.exists?(membership.id)
    assert_equal "secret", subgroup.reload.group_privacy
    assert_equal root.id, subgroup.parent_id, "cleanup must not silently change the access hierarchy"
  end
end
