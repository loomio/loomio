class FixMotionNotVotedCount < ActiveRecord::Migration
  def change
    add_column :motions, :members_count, :integer
    add_column :motions, :voters_count, :integer, null: false, default: 0

    Motion.update_all('voters_count = (yes_votes_count + no_votes_count + abstain_votes_count + block_votes_count)')

    execute "UPDATE motions
            SET members_count = (SELECT COUNT(memberships.id) FROM memberships
                                 WHERE memberships.group_id = discussions.group_id
                                 AND memberships.created_at <= motions.closed_at
                                 AND (memberships.archived_at is null or
                                      memberships.archived_at < motions.closed_at))
            FROM discussions WHERE motions.discussion_id = discussions.id "
  end
end
