class EventParentMigrator
  def self.migrate_some_groups(num = 100)
    FormalGroup.where("not(features ? 'nested_comments')").order("id DESC").limit(num).each do |group|
      EventParentMigrator.delay(queue: :low_priority).migrate_group_id!(group.id)
    end
  end

  def self.migrate_group_id!(group_id)
    group = FormalGroup.find group_id
    return if group.features['nested_comments']
    assign_surface_comment_parents(group)
    assign_reply_comment_parents(group)
    assign_edit_parents(group)
    assign_poll_parents(group)
    group.features['nested_comments'] = true
    group.save
    group.subgroups.find_each { |g| migrate_group_id!(g.id) }
  end

  def self.assign_surface_comment_parents(group)
    group.comments.where("parent_id is null").find_each do |comment|
      next unless created_event = comment.created_event
      next if comment.discussion.author.nil?
      next if created_event.parent_id
      created_event.update(parent: comment.discussion.created_event)
    end
  end

  def self.assign_reply_comment_parents(group)
    total_comments = group.comments.where("parent_id is not null").count
    group.comments.where("parent_id IS NOT NULL").find_each do |comment|
      next unless created_event = comment.created_event
      next if created_event.parent_id
      created_event.update(parent: comment.parent_event)
    end
  end

  def self.assign_edit_parents(group)
    group.discussions.find_each do |discussion|
      discussion.items.where(kind: ["discussion_edited", "poll_edited", "poll_expired"])
                      .where(parent_id: nil).find_each do |event|
        if event.eventable && event.eventable.respond_to?(:created_event)
          event.update(parent: event.eventable.created_event)
        elsif event.eventable.respond_to?(:item) && event.eventable.item.respond_to?(:created_event)
          event.update(parent: event.eventable.item.created_event)
        end
      end
    end
  end

  def self.assign_poll_parents(group)
    group.polls.where("discussion_id is not null").find_each do |poll|
      poll_created_event = poll.created_event
      next if poll_created_event.parent_id
      poll_created_event.update(parent: poll.discussion.created_event) if poll.discussion
      poll.stances.find_each do |stance|
        stance.created_event.update(parent: poll_created_event)
      end
    end
  end
end
