class EventParentMigrator
  def self.migrate_all_groups
    FormalGroup.where("not(features ? 'nested_comments')").find_each do |group|
      next if group.features['nested_comments']
      EventParentMigrator.delay(priority: 1000).migrate_group!(group)
    end
  end

  def self.migrate_some_groups(num)
    FormalGroup.where("not(features ? 'nested_comments')").order("discussions_count DESC").limit(num) do |group|
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
    group.subgroups.find_each { |g| migrate_group!(g) }
  end

  def self.assign_surface_comment_parents(group)
    group.comments.where("parent_id is null").find_each do |comment|
      # dont care if no event exists
      if created_event = comment.created_event
        next if created_event.parent_id
        next unless comment.discussion.author
        if created_event.parent = comment.discussion.created_event
          created_event.save
        end
      end
    end
  end

  def self.assign_reply_comment_parents(group)
    total_comments = group.comments.where("parent_id is not null").count
    group.comments.where("parent_id IS NOT NULL").find_each do |comment|
      # dont care if no event exists
      if created_event = comment.created_event
        next if created_event.parent_id
        parent_event = comment.first_ancestor.created_event
        comment.created_event.update(parent: comment.first_ancestor.created_event)
      end
    end
  end

  def self.assign_edit_parents(group)
    group.discussions.find_each do |discussion|
      discussion.items.where(kind: ["discussion_edited", "poll_expired"])
                      .where(parent_id: nil).find_each do |event|
        event.update(parent: event.eventable.created_event)
      end
      discussion.items.where(kind: ["poll_edited"])
                      .where(parent_id: nil).find_each do |event|
        event.update(parent: event.eventable.item.created_event)
      end
    end
  end

  def self.assign_poll_parents(group)
    group.polls.where("discussion_id is not null").find_each do |poll|
      next unless poll_created_event = poll.created_event
      next if poll_created_event.parent_id
      poll_created_event.update(parent: poll.discussion.created_event)
      poll.stances.find_each do |stance|
        next unless stance_created_event = stance.created_event
        stance_created_event.update(parent: poll_created_event)
      end
    end
  end
end
