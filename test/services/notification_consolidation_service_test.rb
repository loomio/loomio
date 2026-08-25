require "test_helper"
require Rails.root.join("db/migrate/support/notification_consolidation_service")

class NotificationConsolidationServiceTest < ActiveSupport::TestCase
  setup do
    connection.execute("TRUNCATE notification_deliveries, notification_occurrences, notification_consolidation_states")
  end

  test "consolidates receipts into one occurrence with one delivery per recipient" do
    event = events(:public_discussion_comment_event)
    user = users(:user)
    another_user = users(:member)
    create_receipt!(event: event, user: user, viewed: false, translation_values: { "name" => "First" })
    create_receipt!(event: event, user: user, viewed: true, translation_values: { "name" => "Duplicate" })
    create_receipt!(event: event, user: another_user)
    legacy_count = Notification.where(event: event).count

    stats = NotificationConsolidationService.run!(dry_run: false, batch_size: 1)

    assert_equal 3, stats[:receipts_processed]
    assert_equal 1, occurrence_count(event)
    assert_equal 2, delivery_count(event)
    assert_equal legacy_count, Notification.where(event: event).count
    assert_not_nil delivery_viewed_at(event: event, user: user)
    assert_equal({ "name" => "First" }, delivery_translation_values(event: event, user: user))
  end

  test "resumes from its cursor and catches later receipts" do
    event = events(:public_discussion_comment_event)
    create_receipt!(event: event, user: users(:user))
    first = NotificationConsolidationService.run!(dry_run: false, batch_size: 1)
    first_cursor = first.dig(:state, :notification_id_cursor)

    create_receipt!(event: event, user: users(:member))
    second = NotificationConsolidationService.run!(dry_run: false, batch_size: 1)

    assert_operator second.dig(:state, :notification_id_cursor), :>, first_cursor
    assert_equal 1, second[:receipts_processed]
    assert_equal 1, occurrence_count(event)
    assert_equal 2, delivery_count(event)
  end

  test "audit does not populate preparation tables" do
    create_receipt!(event: events(:public_discussion_comment_event), user: users(:user))

    stats = NotificationConsolidationService.run!(dry_run: true)

    assert stats[:dry_run]
    assert_equal 1, stats.dig(:before, :missing_notifications)
    assert_equal 0, connection.select_value("SELECT COUNT(*) FROM notification_occurrences").to_i
    assert_equal 0, connection.select_value("SELECT COUNT(*) FROM notification_deliveries").to_i
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def create_receipt!(event:, user:, viewed: false, translation_values: {})
    Notification.create!(
      event: event,
      user: user,
      actor: users(:admin),
      viewed: viewed,
      translation_values: translation_values
    )
  end

  def occurrence_count(event)
    connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM notification_occurrences
      WHERE legacy_event_id = #{connection.quote(event.id)}
    SQL
  end

  def delivery_count(event)
    connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM notification_deliveries deliveries
      INNER JOIN notification_occurrences occurrences
        ON occurrences.id = deliveries.notification_occurrence_id
      WHERE occurrences.legacy_event_id = #{connection.quote(event.id)}
    SQL
  end

  def delivery_viewed_at(event:, user:)
    delivery_value(event: event, user: user, column: "viewed_at")
  end

  def delivery_translation_values(event:, user:)
    JSON.parse(delivery_value(event: event, user: user, column: "translation_values"))
  end

  def delivery_value(event:, user:, column:)
    connection.select_value(<<~SQL.squish)
      SELECT deliveries.#{column}
      FROM notification_deliveries deliveries
      INNER JOIN notification_occurrences occurrences
        ON occurrences.id = deliveries.notification_occurrence_id
      WHERE occurrences.legacy_event_id = #{connection.quote(event.id)}
        AND deliveries.recipient_type = 'User'
        AND deliveries.recipient_id = #{connection.quote(user.id)}
    SQL
  end
end
