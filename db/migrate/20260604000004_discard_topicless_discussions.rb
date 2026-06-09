class DiscardTopiclessDiscussions < ActiveRecord::Migration[8.0]
  def up
    # 1. Null out dangling topic_id values — topic_id points at a topics row
    #    that no longer exists (the parent group/topic was destroyed but the
    #    discussion was left behind). The FK permits NULL, so clearing these
    #    lets the constraint validate; step 2 discards any still-kept ones.
    execute <<~SQL
      UPDATE discussions
      SET topic_id = NULL
      WHERE topic_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.id = discussions.topic_id)
    SQL

    # 2. Discard kept, topicless discussions. With no topic they have no group
    #    and are unreachable, but still appear in `kept`. Raw SQL is deliberate:
    #    saving through ActiveRecord would fire update_group_counter_caches,
    #    which dereferences the nil topic and raises.
    execute <<~SQL
      UPDATE discussions
      SET discarded_at = NOW()
      WHERE topic_id IS NULL
        AND discarded_at IS NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
