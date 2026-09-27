require "test_helper"
require Rails.root.join("db/migrate/20260927000000_remove_stance_receipts")

class RemoveStanceReceiptsTest < ActiveSupport::TestCase
  test "copies historical invitation dates before removing receipts" do
    poll = PollService.create(params: {
      title: "Anonymous participation",
      poll_type: "proposal",
      anonymous: true,
      group_id: groups(:group).id,
      poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now
    }, actor: users(:admin))
    voter_id = poll.anonymous_poll_voters.first!.voter_id
    invited_at = 2.days.ago.change(usec: 0)
    connection = ActiveRecord::Base.connection
    connection.remove_column(:anonymous_poll_voters, :invited_at)
    connection.create_table(:stance_receipts) do |table|
      table.bigint :poll_id
      table.bigint :voter_id
      table.datetime :invited_at
    end
    connection.execute(<<~SQL.squish)
      INSERT INTO stance_receipts (poll_id, voter_id, invited_at)
      VALUES (#{poll.id}, #{voter_id}, #{connection.quote(invited_at)})
    SQL

    RemoveStanceReceipts.new.up

    assert_not connection.data_source_exists?(:stance_receipts)
    assert_equal invited_at, connection.select_value(<<~SQL.squish).in_time_zone
      SELECT invited_at FROM anonymous_poll_voters
      WHERE poll_id = #{poll.id} AND voter_id = #{voter_id}
    SQL
  end
end
