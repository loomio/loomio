class DiscardTopiclessPolls < ActiveRecord::Migration[8.0]
  def up
    # 1. Null out dangling topic_id values — topic_id points at a topics row
    #    that no longer exists (the parent group/topic was destroyed but the
    #    poll was left behind). The FK permits NULL, so clearing these lets the
    #    constraint validate; step 2 discards any that are still active.
    execute <<~SQL
      UPDATE polls
      SET topic_id = NULL
      WHERE topic_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.id = polls.topic_id)
    SQL

    # 2. Discard active, topicless polls. With no topic they have no group and
    #    no audience, yet Poll.active still selects them — so the hourly
    #    closing-soon sweep (PollService.publish_closing_soon) queues a
    #    PollClosingSoon event that crashes on poll.topic == nil. Discarding
    #    drops them from kept/active.
    #
    #    Raw SQL is deliberate: saving these through ActiveRecord would fire the
    #    update_group_counter_caches after_commit, which dereferences the nil
    #    topic and raises.
    execute <<~SQL
      UPDATE polls
      SET discarded_at = NOW()
      WHERE topic_id IS NULL
        AND discarded_at IS NULL
        AND closed_at IS NULL
        AND opened_at IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
