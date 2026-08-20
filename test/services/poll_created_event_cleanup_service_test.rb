require "test_helper"

class PollCreatedEventCleanupServiceTest < ActiveSupport::TestCase
  INDEX_NAME = "index_events_on_unique_poll_created_event"

  setup do
    ActiveRecord::Base.connection.remove_index(:events, name: INDEX_NAME)
    @user = users(:user)
    @group = groups(:group)
    @poll = PollService.create(params: {
      title: "Standalone Poll",
      poll_type: "proposal",
      poll_option_names: [ "Agree", "Disagree" ],
      closing_at: 5.days.from_now,
      group_id: @group.id
    }, actor: @user)
  end

  teardown do
    ActiveRecord::Base.connection.add_index(
      :events,
      [ :eventable_type, :eventable_id, :kind ],
      unique: true,
      where: "eventable_type = 'Poll' AND kind = 'poll_created'",
      name: INDEX_NAME
    ) unless ActiveRecord::Base.connection.index_exists?(:events, name: INDEX_NAME)
  end

  test "keeps one topic event and reparents children" do
    canonical = @poll.created_event
    duplicate = Event.create!(
      kind: "poll_created",
      eventable: @poll,
      user: @user
    )
    child = Event.create!(
      kind: "poll_edited",
      eventable: @poll,
      parent: duplicate,
      user: @user
    )

    result = PollCreatedEventCleanupService.normalize!

    assert_equal 1, result.fetch(:duplicate_events)
    assert_equal [ canonical.id ], Event.where(eventable: @poll, kind: "poll_created").pluck(:id)
    assert_equal canonical.id, child.reload.parent_id
  end

  test "moves an existing event into the poll topic" do
    event = @poll.created_event
    event.update_columns(
      topic_id: nil,
      parent_id: nil,
      sequence_id: nil,
      position_key: nil
    )

    assert_equal 1, PollCreatedEventCleanupService.normalize!.fetch(:repaired_topics)

    assert_equal @poll.topic_id, event.reload.topic_id
    assert_equal 0, event.sequence_id
    TopicService.verify_integrity!(@poll.topic_id)
  end

  test "creates a missing event" do
    @poll.events.where(kind: "poll_created").delete_all

    assert_equal 1, PollCreatedEventCleanupService.normalize!.fetch(:repaired_topics)

    event = @poll.events.find_by!(kind: "poll_created")
    assert_equal @poll.topic_id, event.topic_id
    assert_equal 0, event.sequence_id
  end

  test "creates a root event for a discarded standalone poll" do
    discarded_at = 1.day.ago
    @poll.update_columns(discarded_at: discarded_at)
    @poll.topic.update_columns(discarded_at: discarded_at)
    @poll.events.where(kind: "poll_created").delete_all

    PollCreatedEventCleanupService.normalize!

    event = @poll.events.find_by!(kind: "poll_created")
    assert_equal @poll.topic_id, event.topic_id
    assert_equal 0, event.sequence_id
    assert_equal "00000", event.position_key
    TopicService.verify_integrity!(@poll.topic_id)
  end

  test "deletes a duplicate timeline event without requiring repair" do
    canonical = @poll.created_event
    duplicate = Event.create!(
      kind: "poll_created",
      eventable: @poll,
      topic: @poll.topic,
      user: @user
    )

    assert_equal 1, PollCreatedEventCleanupService.normalize!.fetch(:duplicate_events)

    assert_equal [ canonical.id ], Event.where(eventable: @poll, kind: "poll_created").pluck(:id)
    assert_not Event.exists?(duplicate.id)
    TopicService.verify_integrity!(@poll.topic_id)
  end

  test "requests repair when timeline children are reparented" do
    canonical = @poll.created_event
    duplicate = Event.create!(
      kind: "poll_created",
      eventable: @poll,
      topic: @poll.topic,
      user: @user
    )
    child = Event.create!(
      kind: "poll_edited",
      eventable: @poll,
      parent: duplicate,
      topic: @poll.topic,
      user: @user
    )
    child.update_columns(parent_id: duplicate.id)

    assert_equal 1, PollCreatedEventCleanupService.normalize!.fetch(:repaired_topics)

    assert_equal canonical.id, child.reload.parent_id
    TopicService.verify_integrity!(@poll.topic_id)
  end

  test "deletes every event belonging to an orphaned poll" do
    orphan_poll_id = Poll.maximum(:id) + 1
    now = Time.current
    Event.insert_all!([
      {
        kind: "poll_created",
        eventable_type: "Poll",
        eventable_id: orphan_poll_id,
        topic_id: @poll.topic_id,
        sequence_id: 10,
        position: 1,
        position_key: "00000-00001",
        depth: 1,
        created_at: now,
        updated_at: now
      },
      {
        kind: "poll_expired",
        eventable_type: "Poll",
        eventable_id: orphan_poll_id,
        topic_id: @poll.topic_id,
        sequence_id: 11,
        position: 2,
        position_key: "00000-00002",
        depth: 1,
        created_at: now,
        updated_at: now
      }
    ])

    PollCreatedEventCleanupService.normalize!

    assert_not Event.where(eventable_type: "Poll", eventable_id: orphan_poll_id).exists?
    TopicService.verify_integrity!(@poll.topic_id)
  end

  test "deletes orphaned poll events when the created event is already missing" do
    orphan_poll_id = Poll.maximum(:id) + 1
    event_id = Event.insert_all!([ {
      kind: "poll_expired",
      eventable_type: "Poll",
      eventable_id: orphan_poll_id,
      topic_id: @poll.topic_id,
      user_id: @user.id,
      created_at: Time.current,
      updated_at: Time.current
    } ]).rows.first.first

    PollCreatedEventCleanupService.normalize!

    assert_not Event.exists?(event_id)
    TopicService.verify_integrity!(@poll.topic_id)
  end
end
