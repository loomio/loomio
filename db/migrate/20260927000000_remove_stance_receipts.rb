class RemoveStanceReceipts < ActiveRecord::Migration[8.1]
  def up
    add_column :anonymous_poll_voters, :invited_at, :datetime

    # Complete historical electorates were copied into anonymous_poll_voters by
    # the anonymous vote migration. Keep their invitation dates before removing
    # receipts that cannot form a reliable named participation record.
    execute <<~SQL.squish
      UPDATE anonymous_poll_voters AS voters
      SET invited_at = receipts.invited_at
      FROM (
        SELECT poll_id, voter_id, MIN(invited_at) AS invited_at
        FROM stance_receipts
        GROUP BY poll_id, voter_id
      ) AS receipts
      WHERE voters.poll_id = receipts.poll_id
        AND voters.voter_id = receipts.voter_id
        AND receipts.invited_at IS NOT NULL
    SQL

    drop_table :stance_receipts
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Removed receipt rows cannot be reconstructed"
  end
end
