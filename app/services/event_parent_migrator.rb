class EventParentMigrator
  def self.migrate_all_groups
    FormalGroup.find_each do |group|
      migrate_group!(group)
    end
  end

  def self.migrate_group!(group)
    assign_surface_comment_parents(group)
    assign_reply_comment_parents(group)
    assign_edit_parents(group)
    assign_poll_parents(group)
    group.features['nested_comments'] = true
    group.save
  end

  def self.assign_surface_comment_parents(group)
    group.comments.where("parent_id is null").each do |comment|
      created_event = comment.created_event
      created_event.parent = comment.discussion.created_event
      created_event.save
    end
  end

  def self.assign_reply_comment_parents(group)
    total_comments = group.comments.where("parent_id is not null").count
    group.comments.where("parent_id IS NOT NULL").each do |comment|
      created_event = comment.created_event
      parent_event = comment.first_ancestor.created_event
      comment.created_event.update(parent: comment.first_ancestor.created_event)
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
      poll_created_event = poll.created_event
      poll_created_event.update(parent: poll.discussion.created_event)
      poll.stances.each do |stance|
        stance.created_event.update(parent: poll_created_event)
      end
    end
  end
end
