class ReplaceMembershipRequestResponseState < ActiveRecord::Migration[8.0]
  def up
    add_column :membership_requests, :approved_at, :datetime
    add_column :membership_requests, :declined_at, :datetime
    rename_column :membership_requests, :response_comment, :decline_reason

    execute <<~SQL.squish
      UPDATE membership_requests
      SET approved_at = responded_at
      WHERE response = 'approved'
    SQL

    execute <<~SQL.squish
      UPDATE membership_requests
      SET declined_at = responded_at
      WHERE response IN ('declined', 'ignored')
    SQL

    remove_column :membership_requests, :response, :string
    remove_column :membership_requests, :responded_at, :datetime
  end

  def down
    add_column :membership_requests, :response, :string
    add_column :membership_requests, :responded_at, :datetime

    execute <<~SQL.squish
      UPDATE membership_requests
      SET response = CASE
            WHEN approved_at IS NOT NULL THEN 'approved'
            WHEN declined_at IS NOT NULL THEN 'declined'
          END,
          responded_at = COALESCE(approved_at, declined_at)
    SQL

    rename_column :membership_requests, :decline_reason, :response_comment
    remove_column :membership_requests, :approved_at, :datetime
    remove_column :membership_requests, :declined_at, :datetime
  end
end
