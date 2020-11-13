module ScopeService
  def self.for_discussion_collection(collection, current_user)
    h = {}
    discussion_ids = collection.pluck(:id)
    group_ids = collection.pluck(:group_id)
    poll_ids = ScopeService.add_polls_by_discussion_id(h, discussion_ids)
    ScopeService.add_poll_options_by_poll_id(h, poll_ids)
    parent_group_ids = ScopeService.add_groups_by_id(h, group_ids, :return_parent_ids)
    all_group_ids = group_ids.concat(parent_group_ids)
    ScopeService.add_groups_by_id(h, all_group_ids)
    ScopeService.add_memberships_by_group_id(h, all_group_ids, current_user.id)
    ScopeService.add_discussions_by_id(h, discussion_ids)
    ScopeService.add_stances_by_poll_id(h, poll_ids, current_user.id)
    ScopeService.add_discussion_readers_by_discussion_id(h, discussion_ids, current_user.id)
    ScopeService.add_events_by_kind_and_discussion_id(h, 'new_discussion', discussion_ids)
    ScopeService.add_events_by_kind_and_discussion_id(h, 'discussion_forked', discussion_ids)
    ScopeService.add_events_by_kind_and_poll_id(h, 'poll_created', poll_ids)
    ScopeService.add_subscriptions_by_group_id(h, all_group_ids)
    h
  end
  # in controller
  # ScopeService.add_groups_by_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def self.add_groups_by_id(scope, group_ids, return_parent_ids = nil)
    scope[:groups_by_id] ||= {}
    ids = []
    Group.includes(:default_group_cover).where(id: group_ids).each do |group|
      if return_parent_ids
        ids.push group.parent_id
      else
        ids.push group.id
      end

      scope[:groups_by_id][group.id] = group
    end
    ids
  end

  def self.add_subscriptions_by_group_id(scope, group_ids)
    scope[:subscriptions_by_group_id] ||=  {}
    Group.includes(:subscription).where(id: group_ids).each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription
    end
  end

  # in controller
  # ScopeService.add_my_memberships_by_group_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def self.add_memberships_by_group_id(scope, group_ids, user_id)
    scope[:memberships_by_group_id] ||= {}
    ids = []
    Membership.includes(:inviter).where(group_id: group_ids, user_id: user_id).each do |m|
      ids.push m.id
      scope[:memberships_by_group_id][m.group_id] = m
    end
    ids
  end

  def self.add_polls_by_discussion_id(scope, discussion_ids)
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    Poll.includes(:poll_options, :author).where(discussion_id: discussion_ids).each do |poll|
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
  end

  def self.add_poll_options_by_poll_id(scope, poll_ids)
    scope[:poll_options_by_poll_id] ||= {}
    PollOption.where(poll_id: poll_ids).each do |poll_option|
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  # what if we pass a relation?
  def self.add_stances_by_poll_id(scope, poll_ids, user_id)
    scope[:stances_by_poll_id] ||= {}
    ids = []
    Stance.includes(:stance_choices, :participant, :poll).where(poll_id: poll_ids, participant_id: user_id).each do |stance|
      ids.push stance
      scope[:stances_by_poll_id][stance.poll_id] = stance
    end
    ids
  end

  def self.add_discussion_readers_by_discussion_id(scope, discussion_ids, user_id)
    scope[:discussion_readers_by_discussion_id] ||= {}
    ids = []
    DiscussionReader.where(discussion_id: discussion_ids, user_id: user_id).each do |dr|
      ids.push dr.id
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
    ids
  end

  def self.add_created_events_by_discussion_id(scope, discussion_ids)
    scope[:created_events_by_discussion_id] ||= {}
    ids = []
    Event.includes(:user, :parent).where(kind: 'new_discussion', eventable_id: discussion_ids).each do |event|
      scope[:created_events_by_discussion_id][event.eventable_id] = event
    end
    ids
  end

  def self.add_events_by_kind_and_discussion_id(scope, kind, discussion_ids)
    scope[:events_by_discussion_id] ||= {}
    scope[:events_by_discussion_id][kind] ||= {}
    ids = []
    Event.includes(:user, :parent).where(kind: kind, eventable_id: discussion_ids).each do |event|
      scope[:events_by_discussion_id][kind][event.eventable_id] = event
    end
    ids
  end

  def self.add_events_by_kind_and_poll_id(scope, kind, poll_ids)
    scope[:events_by_poll_id] ||= {}
    scope[:events_by_poll_id][kind] ||= {}
    ids = []
    Event.includes(:user, :parent).where(kind: kind, eventable_id: poll_ids).each do |event|
      scope[:events_by_poll_id][kind][event.eventable_id] = event
    end
    ids
  end

  def self.add_discussions_by_id(scope, discussion_ids)
    scope[:discussions_by_id] ||= {}
    Discussion.includes(:author).where(id: discussion_ids).each do |d|
      scope[:discussions_by_id][d.id] = d
    end
  end
end
