class MoveClosedAndPinnedToTopics < ActiveRecord::Migration[7.2]
  def up
    add_column :topics, :closed_at, :datetime, precision: nil
    add_column :topics, :closer_id, :integer
    add_column :topics, :pinned_at, :datetime, precision: nil

    execute <<~SQL
      UPDATE topics
      SET closed_at  = d.closed_at,
          closer_id  = d.closer_id,
          pinned_at  = d.pinned_at
      FROM discussions d
      WHERE topics.topicable_type = 'Discussion'
        AND topics.topicable_id  = d.id
    SQL

    remove_column :discussions, :closed_at
    remove_column :discussions, :closer_id
    remove_column :discussions, :pinned_at
  end

  def down
    add_column :discussions, :closed_at, :datetime, precision: nil
    add_column :discussions, :closer_id, :integer
    add_column :discussions, :pinned_at, :datetime, precision: nil

    execute <<~SQL
      UPDATE discussions
      SET closed_at  = t.closed_at,
          closer_id  = t.closer_id,
          pinned_at  = t.pinned_at
      FROM topics t
      WHERE t.topicable_type = 'Discussion'
        AND t.topicable_id  = discussions.id
    SQL

    remove_column :topics, :closed_at
    remove_column :topics, :closer_id
    remove_column :topics, :pinned_at
  end
end
