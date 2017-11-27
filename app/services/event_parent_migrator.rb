class EventParentMigrator
  def self.migrate_all_groups
    FormalGroup.find_each do |group|
      next if group.features['nested_comments']
      EventParentMigrator.delay(priority: 1000).migrate_group!(group)
    end
  end

  def self.migrate_group!(group)
    assign_surface_comment_parents(group)
    assign_reply_comment_parents(group)
    assign_edit_parents(group)
    assign_poll_parents(group)
    group.features['nested_comments'] = true
    group.save
    group.subgroups.each { |g| migrate_group!(g) }
  end

  def self.assign_surface_comment_parents(group)
    group.comments.where("parent_id is null").each do |comment|
      # dont care if no event exists
      if created_event = comment.created_event
        next if created_event.parent_id
        next unless comment.discussion.author
        created_event.parent = comment.discussion.created_event ||
          Events::NewDiscussion.create!(
            kind: 'new_discussion',
            user: comment.discussion.author,
            announcement: false,
            eventable: comment.discussion,
            created_at: comment.discussion.created_at
          )
        created_event.save
      end
    end
  end

  def self.assign_reply_comment_parents(group)
    total_comments = group.comments.where("parent_id is not null").count
    group.comments.where("parent_id IS NOT NULL").each do |comment|
      # dont care if no event exists
      if created_event = comment.created_event
        next if created_event.parent_id
        parent_event = comment.first_ancestor.created_event
        comment.created_event.update(parent: comment.first_ancestor.created_event)
      end
    end
  end

  def self.assign_edit_parents(group)
    group.discussions.each do |discussion|
      discussion.items.where(kind: "discussion_edited").each do |event|
        event.update(parent: discussion.created_event)
      end
    end
  end

  def self.assign_poll_parents(group)
    group.polls.where("discussion_id is not null").each do |poll|
      poll_created_event = poll.created_event ||
        Events::PollCreated.create!(kind: "poll_created",
                                    user: poll.author,
                                    eventable: poll,
                                    parent: poll.parent_event,
                                    announcement: false,
                                    discussion: poll.discussion,
                                    created_at: poll.created_at)
      next if poll_created_event.parent_id
      poll_created_event.update(parent: poll.discussion.created_event)
      poll.stances.each do |stance|
        next unless stance_created_event = stance.created_event
        stance_created_event.update(parent: poll_created_event)
      end
    end
  end
end
