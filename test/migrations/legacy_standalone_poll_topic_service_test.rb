require "test_helper"
require Rails.root.join("db/migrate/support/legacy_standalone_poll_topic_service")

class LegacyStandalonePollTopicServiceTest < ActiveSupport::TestCase
  test "attaches and repairs a legacy standalone poll stance event" do
    poll = PollService.create(
      params: {
        title: "Legacy standalone poll",
        poll_type: "proposal",
        poll_option_names: [ "Agree", "Disagree" ],
        closing_at: 3.days.from_now,
        group_id: groups(:group).id
      },
      actor: users(:admin)
    )
    stance = poll.stances.find_by!(participant: users(:user), latest: true)
    stance.update_columns(cast_at: Time.current, reason: "Visible response")
    poll.update_columns(closed_at: Time.current)

    with_legacy_event_schema do
      legacy_event = LegacyEventRecord.create!(
        kind: "stance_created",
        eventable_type: "Stance",
        eventable_id: stance.id,
        user_id: stance.participant_id,
        created_at: stance.cast_at,
        updated_at: stance.cast_at
      )

      stats = LegacyStandalonePollTopicService.backfill_stance_events(mark_closed_read: false)

      legacy_event.reload
      assert_equal poll.topic_id, legacy_event.topic_id
      assert_not_nil legacy_event.sequence_id
      assert_not_nil legacy_event.position_key
      assert_equal 1, stats[:events]
      assert_equal 1, stats[:topics]
    end
  end

  private

  def with_legacy_event_schema
    connection = ActiveRecord::Base.connection
    connection.rename_table(:topic_items, :events)
    connection.rename_column(:events, :itemable_type, :eventable_type)
    connection.rename_column(:events, :itemable_id, :eventable_id)
    connection.rename_column(:events, :itemable_version_id, :eventable_version_id)
    connection.change_column_null(:events, :topic_id, true)
    LegacyEventRecord.reset_column_information
    yield
  ensure
    if connection.data_source_exists?(:events)
      connection.execute("DELETE FROM events WHERE topic_id IS NULL")
      connection.change_column_null(:events, :topic_id, false)
      connection.rename_column(:events, :eventable_type, :itemable_type)
      connection.rename_column(:events, :eventable_id, :itemable_id)
      connection.rename_column(:events, :eventable_version_id, :itemable_version_id)
      connection.rename_table(:events, :topic_items)
      TopicItem.reset_column_information
    end
  end
end
