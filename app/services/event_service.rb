class EventParentMigrator
  def self.migrate_group!(group)
    assign_comment_parents(group)
    assign_stance_parents(group)
    group.features['nested_comments'] = true
    group.save
  end

  def assign_comment_parents(group)
    # find parents for new_comment events
    ActiveRecord::Base.connection.execute(
      "UPDATE events
       SET parent_id = parent_events.id
       FROM events parent_events
         INNER JOIN comments ON parent_events.eventable_id = comments.id
                AND parent_events.eventable_type = 'Comment'
       WHERE comments.parent_id IS NOT NULL
       AND parent_events.kind = 'new_comment'
       AND parent_events.discussion_id IN (#{group.discussion_ids.join(',')})")

    # Equivalent ruby:
    # total_comments = Comment.where("parent_id is not null").count
    # Comment.order("id DESC").limit(10000).where("parent_id IS NOT NULL").each do |comment|
    #   puts "#{comment.id} of #{total_comments} comments"
    #   event = comment.events.find_by(kind: 'new_comment')
    #   parent_event = comment.parent.events.find_by(kind: 'new_comment')
    #   return unless event && parent_event
    #   event.update_attribute(:parent_id, parent_event.id)
    # end
  end

  def assign_stance_parents(group)
    total_polls = group.polls.count
    group.polls.find_each do |poll|
      puts "#{poll.id} of #{total_polls} polls"
      next unless parent_event = poll.events.find_by(kind: "poll_created")
      Event.where(kind: "stance_created",
                  eventable_type: "Stance",
                  eventable_id: poll.stance_ids)
           .update_all(parent_id: parent_event.id)
    end
  end
end
