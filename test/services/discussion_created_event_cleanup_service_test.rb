require "test_helper"

class DiscussionCreatedEventCleanupServiceTest < ActiveSupport::TestCase
  INDEX_NAME = "index_events_on_unique_discussion_created_event"

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.remove_index(:events, name: INDEX_NAME) if @connection.index_exists?(:events, name: INDEX_NAME)
    @user = users(:user)
    @group = groups(:group)
    @discussion = DiscussionService.create(
      params: { title: "Discussion", group_id: @group.id },
      actor: @user
    )
  end

  teardown do
    @connection.add_index(
      :events,
      [ :eventable_type, :eventable_id, :kind ],
      unique: true,
      where: "eventable_type = 'Discussion' AND kind = 'new_discussion'",
      name: INDEX_NAME
    ) unless @connection.index_exists?(:events, name: INDEX_NAME)
  end

  test "creates and repairs a missing discussion root" do
    root = @discussion.created_event
    child = Event.create!(
      kind: "discussion_closed",
      eventable: @discussion,
      topic: @discussion.topic,
      user: @user
    )
    root.delete

    result = DiscussionCreatedEventCleanupService.normalize!

    assert_equal 1, result.fetch(:inserted_events)
    new_root = @discussion.events.find_by!(kind: "new_discussion")
    assert_equal 0, new_root.sequence_id
    assert_equal new_root.id, child.reload.parent_id
    TopicService.verify_integrity!(@discussion.topic_id)
  end

  test "creates a root for an empty discarded discussion topic" do
    discarded_at = 1.day.ago
    @discussion.update_columns(discarded_at: discarded_at)
    @discussion.topic.update_columns(discarded_at: discarded_at)
    @discussion.created_event.delete

    DiscussionCreatedEventCleanupService.normalize!

    root = @discussion.events.find_by!(kind: "new_discussion")
    assert_equal 0, root.sequence_id
    assert_equal "00000", root.position_key
    TopicService.verify_integrity!(@discussion.topic_id)
  end

  test "deletes every event belonging to an orphaned discussion" do
    orphan_discussion_id = Discussion.maximum(:id) + 1
    now = Time.current
    Event.insert_all!([
      {
        kind: "new_discussion",
        eventable_type: "Discussion",
        eventable_id: orphan_discussion_id,
        created_at: now,
        updated_at: now
      },
      {
        kind: "discussion_edited",
        eventable_type: "Discussion",
        eventable_id: orphan_discussion_id,
        created_at: now,
        updated_at: now
      }
    ])

    result = DiscussionCreatedEventCleanupService.normalize!

    assert_equal 2, result.fetch(:orphan_events)
    assert_not Event.where(
      eventable_type: "Discussion",
      eventable_id: orphan_discussion_id
    ).exists?
  end
end
