require "test_helper"
require Rails.root.join("db/migrate/support/legacy_topic_event_repair_service")

class LegacyTopicEventRepairServiceTest < ActiveSupport::TestCase
  test "repairs chronology and reader ranges before delivery volume columns exist" do
    topic_id = topics(:discussion_topic).id
    reader_ids = [topic_readers(:guest_loud_reader).id, topic_readers(:former_guest_loud_reader).id]

    with_legacy_schema do |connection|
      root = LegacyEventRecord.find_by!(topic_id: topic_id, kind: "new_discussion")
      LegacyEventRecord.where(topic_id: topic_id).where.not(id: root.id).delete_all
      first = insert_event!(topic_id, created_at: 2.days.ago, sequence_id: 7)
      second = insert_event!(topic_id, created_at: 1.day.ago, parent_id: first.id)
      connection.execute("UPDATE topic_readers SET read_ranges_string = '0-1,8-12' WHERE topic_id = #{topic_id}")
      readers_before = connection.select_all("SELECT * FROM topic_readers WHERE topic_id = #{topic_id} ORDER BY id").to_a
      topic_before = connection.select_one("SELECT * FROM topics WHERE id = #{topic_id}")

      LegacyTopicEventRepairService.repair!(topic_id)

      assert_equal [0, 1, 2], LegacyEventRecord.where(topic_id: topic_id).order(:sequence_id).pluck(:sequence_id)
      assert_equal [nil, 0, "00000", 1], root.reload.attributes.values_at("parent_id", "depth", "position_key", "child_count")
      assert_equal [root.id, 1, "00000-00001", 1], first.reload.attributes.values_at("parent_id", "depth", "position_key", "child_count")
      assert_equal [first.id, 2, "00000-00001-00001", 0], second.reload.attributes.values_at("parent_id", "depth", "position_key", "child_count")
      topic_after = connection.select_one("SELECT * FROM topics WHERE id = #{topic_id}")
      assert_equal 3, topic_after.fetch("items_count")
      assert_equal "0-2", topic_after.fetch("ranges_string")
      assert_equal second.created_at, topic_after.fetch("last_activity_at")
      changed_topic_fields = %w[items_count ranges_string last_activity_at]
      assert_equal topic_before.except(*changed_topic_fields), topic_after.except(*changed_topic_fields)
      readers_after = connection.select_all("SELECT * FROM topic_readers WHERE topic_id = #{topic_id} ORDER BY id").to_a
      assert_equal readers_before.map { |row| row.except("read_ranges_string") }, readers_after.map { |row| row.except("read_ranges_string") }
      assert_equal ["0-1", "0-1"], readers_after.select { |row| reader_ids.include?(row.fetch("id")) }.map { |row| row.fetch("read_ranges_string") }

      snapshot = LegacyEventRecord.where(topic_id: topic_id).order(:id).map(&:attributes)
      LegacyTopicEventRepairService.repair!(topic_id)
      assert_equal snapshot, LegacyEventRecord.where(topic_id: topic_id).order(:id).map(&:attributes)
      assert_equal readers_after, connection.select_all("SELECT * FROM topic_readers WHERE topic_id = #{topic_id} ORDER BY id").to_a
    end
  end

  test "creates a missing discussion root without loading current application models" do
    topic_id = topics(:direct_topic).id
    discussion = discussions(:direct_discussion)
    owner = discussion.attributes.slice("id", "author_id", "created_at")

    with_legacy_schema do |connection|
      LegacyEventRecord.where(topic_id: topic_id).delete_all
      connection.execute("UPDATE topic_readers SET read_ranges_string = NULL WHERE topic_id = #{topic_id}")

      LegacyTopicEventRepairService.repair!(topic_id)

      assert_root!(topic_id, "Discussion", "new_discussion", owner)
      assert_equal [""], connection.select_values("SELECT DISTINCT read_ranges_string FROM topic_readers WHERE topic_id = #{topic_id}")
    end
  end

  test "creates a missing poll root before current poll enum columns exist" do
    topic_id = topics(:trial_cleanup_poll).id
    owner = polls(:trial_cleanup_poll).attributes.slice("id", "author_id", "created_at")

    with_legacy_schema do
      LegacyEventRecord.where(topic_id: topic_id).delete_all

      LegacyTopicEventRepairService.repair!(topic_id)

      assert_root!(topic_id, "Poll", "poll_created", owner)
    end
  end

  private

  def insert_event!(topic_id, created_at:, sequence_id: nil, parent_id: nil)
    LegacyEventRecord.create!(
      topic_id: topic_id, kind: "new_comment", eventable_type: "Comment", eventable_id: 1,
      sequence_id: sequence_id, parent_id: parent_id, created_at: created_at, updated_at: created_at
    )
  end

  def assert_root!(topic_id, type, kind, owner)
    root = LegacyEventRecord.find_by!(topic_id: topic_id)
    assert_equal [type, owner.fetch("id"), kind, owner.fetch("author_id"), owner.fetch("created_at")],
      root.attributes.values_at("eventable_type", "eventable_id", "kind", "user_id", "created_at")
    assert_equal [0, 0, 0, "00000"], root.attributes.values_at("sequence_id", "depth", "position", "position_key")
    row = ActiveRecord::Base.connection.select_one("SELECT * FROM topics WHERE id = #{topic_id}")
    assert_equal 1, row.fetch("items_count")
    assert_equal "0-0", row.fetch("ranges_string")
    assert_equal owner.fetch("created_at"), row.fetch("last_activity_at")
  end

  # Fixtures use today's schema. Restore the pre-cutover names and clear model
  # caches so a warmed enum type cannot hide the upgrade failure.
  def with_legacy_schema
    connection = ActiveRecord::Base.connection
    changes = []
    connection.rename_table(:topic_items, :events)
    changes << [:table, :topic_items, :events]
    [
      [:events, :itemable_type, :eventable_type],
      [:events, :itemable_id, :eventable_id],
      [:events, :itemable_version_id, :eventable_version_id],
      [:topic_readers, :volume_email, :volume],
      [:topic_readers, :volume_push, :later_volume_push],
      [:memberships, :volume_email, :volume],
      [:memberships, :volume_push, :later_volume_push],
      [:users, :volume_email_default, :default_membership_volume],
      [:users, :volume_push_default, :later_volume_push_default]
    ].each do |table, current, legacy|
      connection.rename_column(table, current, legacy)
      changes << [:column, table, current, legacy]
    end
    reset_record_columns
    yield connection
  ensure
    changes.reverse_each do |kind, table, current, legacy|
      if kind == :table
        connection.rename_table(current, table)
      else
        connection.rename_column(table, legacy, current)
      end
    end
    reset_record_columns
  end

  def reset_record_columns
    ActiveRecord::Base.descendants.each(&:reset_column_information)
  end
end
