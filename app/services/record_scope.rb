class RecordScope
  attr_accessor :scope
  attr_accessor :exclude_types

  def initialize
    @scope = {}
    @exclude_types = []
  end

  def self.for_groups(group_ids, user_id)
    obj = new
    all_group_ids = obj.add_groups_by_id(group_ids)
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    puts "!!!!!!group colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_events(collection, discussion_id, current_user, exclude_types)
    obj = new
    obj.exclude_types = exclude_types
    discussion_ids = [discussion_id]
    group_ids = Discussion.where(id: discussion_ids).pluck(:group_id)
    comment_ids = collection.where(eventable_type: 'Comment').except(:order).pluck(:eventable_id)
    stance_ids = collection.where(eventable_type: 'Stance').except(:order).pluck(:eventable_id)

    all_group_ids = obj.add_groups_by_id(group_ids)
    poll_ids = obj.add_polls_by_discussion_id(discussion_id)
    obj.add_events_by_id(collection.pluck(:parent_id))
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_groups_by_id(all_group_ids)
    obj.add_memberships_by_group_id(all_group_ids, current_user.id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_comments_by_id(comment_ids)
    obj.add_stances_by_id(stance_ids)
    obj.add_stances_by_poll_id(poll_ids, current_user.id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, current_user.id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    puts "!!!!!!event colleciton loaded!!!!!!!!!"
    obj
  end

  def self.for_discussions(collection, current_user)
    obj = new
    discussion_ids = collection.pluck(:id)
    all_group_ids = obj.add_groups_by_id(collection.pluck(:group_id))
    poll_ids = obj.add_polls_by_discussion_id(discussion_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_memberships_by_group_id(all_group_ids, current_user.id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_stances_by_poll_id(poll_ids, current_user.id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, current_user.id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    puts "!!!!!!discussion colleciton loaded!!!!!!!!!"
    obj
  end

  # in controller
  # ScopeService.add_groups_by_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_groups_by_id(group_ids)
    scope[:groups_by_id] ||= {}
    return [] if group_ids.empty?
    ids = []
    parent_ids = []
    Group.with_serializer_includes.where(id: group_ids).each do |group|
      ids.push group.id
      parent_ids.push group.parent_id if group.parent_id
      scope[:groups_by_id][group.id] = group
    end
    ids.concat add_groups_by_id(parent_ids)
  end

  def add_subscriptions_by_group_id(group_ids)
    scope[:subscriptions_by_group_id] ||=  {}
    Group.with_serializer_includes.where(id: group_ids).each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription
    end
  end

  # in controller
  # ScopeService.add_my_memberships_by_group_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_memberships_by_group_id(group_ids, user_id)
    scope[:memberships_by_group_id] ||= {}
    ids = []
    Membership.with_serializer_includes.where(group_id: group_ids, user_id: user_id).each do |m|
      ids.push m.id
      scope[:memberships_by_group_id][m.group_id] = m
    end
    ids
  end

  def add_polls_by_discussion_id(discussion_ids)
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    ids = []
    Poll.with_serializer_includes.where(discussion_id: discussion_ids).each do |poll|
      ids.push poll.id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
    ids
  end

  def add_events_by_id(event_ids)
    scope[:events_by_id] ||= {}
    parent_ids = []
    Event.with_serializer_includes.where(id: event_ids).each do |event|
      parent_ids.push(event.parent_id) if event.parent_id
      scope[:events_by_id][event.id] = event
    end
    add_events_by_id(parent_ids) if parent_ids.any?
    parent_ids
  end

  def add_comments_by_id(comment_ids)
    scope[:comments_by_id] ||= {}
    parent_ids = []
    Comment.with_serializer_includes.where(id: comment_ids).each do |comment|
      scope[:comments_by_id][comment.id] = comment
      parent_ids.push comment.parent_id if comment.parent_id
    end
    add_comments_by_id(parent_ids) if parent_ids.any?
  end

  def add_outcomes_by_poll_id(poll_ids)
    scope[:outcomes_by_id] ||= {}
    scope[:outcomes_by_poll_id] ||= {}
    Outcome.with_serializer_includes.where(poll_id: poll_ids).each do |outcome|
      scope[:outcomes_by_id][outcome.id] = outcome
      scope[:outcomes_by_poll_id][outcome.poll_id] = outcome if outcome.latest
    end
  end

  def add_polls_by_id(poll_ids)
    scope[:polls_by_id] ||= {}
    Poll.with_serializer_includes.where(id: poll_ids).each do |poll|
      scope[:polls_by_id][poll.id] = poll
    end
  end

  def add_poll_options_by_poll_id(poll_ids)
    scope[:poll_options_by_poll_id] ||= {}
    PollOption.with_serializer_includes.where(poll_id: poll_ids).each do |poll_option|
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  def add_stances_by_id(stance_ids)
    scope[:stances_by_id] ||= {}
    Stance.with_serializer_includes.where(id: stance_ids).each do |stance|
      scope[:stances_by_id][stance.id] = stance
    end
  end

  def add_stances_by_poll_id(poll_ids, user_id)
    scope[:stances_by_id] ||= {}
    scope[:stances_by_poll_id] ||= {}
    ids = []
    Stance.with_serializer_includes.where(poll_id: poll_ids, participant_id: user_id).each do |stance|
      ids.push stance
      scope[:stances_by_id][stance.id] = stance
      scope[:stances_by_poll_id][stance.poll_id] = stance
    end
    ids
  end

  def add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    scope[:discussion_readers_by_discussion_id] ||= {}
    ids = []
    DiscussionReader.with_serializer_includes.
                     where(discussion_id: discussion_ids, user_id: user_id).each do |dr|
      ids.push dr.id
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
    ids
  end

  def add_created_events_by_discussion_id(discussion_ids)
    scope[:created_events_by_discussion_id] ||= {}
    ids = []
    Event.with_serializer_includes.where(kind: 'new_discussion', eventable_id: discussion_ids).each do |event|
      scope[:created_events_by_discussion_id][event.eventable_id] = event
    end
    ids
  end

  def add_events_by_kind_and_discussion_id(kind, discussion_ids)
    scope[:events_by_discussion_id] ||= {}
    scope[:events_by_discussion_id][kind] ||= {}
    ids = []
    Event.with_serializer_includes.where(kind: kind, eventable_id: discussion_ids).each do |event|
      scope[:events_by_discussion_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_events_by_kind_and_poll_id(kind, poll_ids)
    scope[:events_by_poll_id] ||= {}
    scope[:events_by_poll_id][kind] ||= {}
    ids = []
    Event.with_serializer_includes.where(kind: kind, eventable_id: poll_ids).each do |event|
      scope[:events_by_poll_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_discussions_by_id(discussion_ids)
    scope[:discussions_by_id] ||= {}
    Discussion.with_serializer_includes.where(id: discussion_ids).each do |d|
      scope[:discussions_by_id][d.id] = d
    end
  end
end
