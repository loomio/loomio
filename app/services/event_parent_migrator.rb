class EventParentMigrator
  def self.migrate_group!(group)
    assign_comment_parents(group)
    assign_stance_parents(group)
    group.features['nested_comments'] = true
    group.save
  end

  def self.assign_comment_parents(group)
    total_comments = group.comments.where("parent_id is not null").count
    group.comments.where("parent_id IS NOT NULL").find_each do |comment|
      puts "#{comment.id} of #{total_comments} comments"
      event = comment.events.where(kind: "new_comment").first
      parent_event = comment.parent_event
      if event && parent_event
        event.update_attribute(:parent_id, parent_event.id)
        parent_event.update_child_count
      end
    end
  end

  def self.assign_stance_parents(group)
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
