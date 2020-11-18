class RecordCache
  attr_accessor :scope
  attr_accessor :exclude_types

  def initialize(exclude_types)
    @scope = {}
    @exclude_types = exclude_types
    @user_ids = []
  end

  def fetch(key_or_keys, id)
    (scope.dig(*Array(key_or_keys)) || {}).fetch(id) do
      if block_given?
        yield
      else
        raise "scope missing preloaded model: #{key_or_keys} #{id}"
      end
    end
  end

  def self.for_collection(collection, user_id, exclude_types = [])
    return unless item = collection.first
    if item.is_a? Discussion then for_discussions(collection, user_id, exclude_types)
    elsif item.is_a? Reaction then for_reactions(collection, user_id, exclude_types)
    elsif item.is_a? Notification then for_notifications(collection, user_id, exclude_types)
    elsif item.is_a? Group then for_groups(collection, user_id, exclude_types)
    elsif item.is_a? Event then for_events(collection, user_id, exclude_types)
    elsif item.is_a? Membership then for_memberships(collection, user_id, exclude_types)
    elsif item.is_a? Poll then for_polls(collection, user_id, exclude_types)
    elsif item.is_a? Outcome then for_outcomes(collection, user_id, exclude_types)
    elsif item.is_a? Stance then for_stances(collection, user_id, exclude_types)
    elsif item.is_a? User then for_users(collection, user_id, exclude_types)
    elsif item.is_a? DiscussionReader then for_discussion_readers(collection, user_id, exclude_types)
    elsif item.is_a? Comment then for_comments(collection, user_id, exclude_types)
    elsif item.is_a? MembershipRequest then for_membership_requests(collection, user_id, exclude_types)
    elsif item.is_a? Document then for_documents(collection, user_id, exclude_types)
    elsif item.is_a? PaperTrail::Version then for_papertrail_versions(collection, user_id, exclude_types)
    elsif item.is_a? Tag then for_tags(collection, user_id, exclude_types)
    else
      raise "unrecognised item: #{item.class}"
    end
  end

  def self.for_tags(collection, user_id, exclude_types)
    obj = new(exclude_types)
    obj.add_groups_by_id(collection.pluck(:group_id))
    obj
  end

  def self.for_papertrail_versions(collection, user_id, exclude_types)
    obj = new(exclude_types)
    obj
  end

  def self.for_documents(collection, user_id, exclude_types)
    obj = new(exclude_types)
    obj.add_users_by_id(collection.map(&:author_id))
    obj
  end

  def self.for_membership_requests(collection, user_id, exclude_types)
    obj = new(exclude_types)
    obj.add_users_by_id(collection.map(&:requestor_id))
    obj.add_users_by_id(collection.map(&:responder_id))
    obj
  end

  def self.for_discussion_readers(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    discussion_ids = collection.map(&:discussion_id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_users_by_id(collection.map(&:user_id))
    obj
  end

  def self.for_users(collection, user_id, exclude_types = [])
    new(exclude_types)
  end

  def self.for_reactions(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    obj.add_reactions_by_id(collection.map(&:id))
    obj.add_users_by_id(collection.map(&:user_id))
    obj
  end

  def self.for_comments(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    obj.add_comments_by_id(collection)
    # discussion_ids = collection.pluck(:discussion_id)
    # obj.add_discussions_by_id(discussion_ids)
    # obj.add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    # obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_users_by_id
    obj
  end

  def self.for_notifications(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    obj.add_events_by_id(collection.map(&:event_id))
    # obj.add_users_by_id(collection.pluck(:user_id).uniq)
    obj
  end

  def self.for_groups(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    all_group_ids = obj.add_groups_by_id(collection.map(&:id))
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    obj.add_users_by_id
    obj
  end

  def self.for_memberships(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    obj.add_groups_by_id(collection.map(&:group_id))
    obj.add_memberships_by_id(collection)
    obj.add_users_by_id
    obj
  end

  def self.for_events(collection, user_id, exclude_types = [])
    obj = new(exclude_types)

    discussion_ids = []
    comment_ids = []
    stance_ids = []
    outcome_ids = []
    poll_ids = []
    reaction_ids = []
    collection.each do |e|
      discussion_ids.push e.discussion_id
      comment_ids.push e.eventable_id if e.eventable_type == 'Comment'
      stance_ids.push e.eventable_id if e.eventable_type == 'Stance'
      discussion_ids.push e.eventable_id if e.eventable_type == 'Discussion'
      outcome_ids.push e.eventable_id if e.eventable_type == 'Outcome'
      reaction_ids.push e.eventable_id if e.eventable_type == 'Reaction'
    end
    # discussion_ids = collection.map(&:discussion_id).compact.uniq
    group_ids = Discussion.where(id: discussion_ids).pluck(:group_id)
    # comment_ids = collection.where(eventable_type: 'Comment').map(&:eventable_id)
    # stance_ids = collection.where(eventable_type: 'Stance').map(&:eventable_id)

    all_group_ids = obj.add_groups_by_id(group_ids)
    poll_ids.concat obj.add_polls_by_discussion_id(discussion_ids)
    obj.add_events_by_id(collection.map(&:parent_id))
    obj.add_outcomes_by_poll_id(poll_ids)
    poll_ids.concat obj.add_outcomes_by_id(ids: outcome_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_polls_by_id(poll_ids)
    obj.add_groups_by_id(all_group_ids)
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_comments_by_id(ids: comment_ids)
    obj.add_stances_by_id(stance_ids)
    obj.add_reactions_by_id(reaction_ids)
    obj.add_stances_by_poll_id(poll_ids, user_id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    obj
  end

  def self.for_discussions(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    discussion_ids = collection.map(&:id)
    all_group_ids = obj.add_groups_by_id(collection.map(&:group_id))
    poll_ids = obj.add_polls_by_discussion_id(discussion_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_stances_by_poll_id(poll_ids, user_id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    obj
  end

  def self.for_polls(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    poll_ids = collection.map(&:id)
    discussion_ids = collection.map(&:discussion_id).compact
    all_group_ids = obj.add_groups_by_id(collection.map(&:group_id))
    obj.add_polls_by_id(poll_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_memberships_by_group_id(all_group_ids, user_id)
    obj.add_discussions_by_id(discussion_ids)
    obj.add_stances_by_poll_id(poll_ids, user_id)
    obj.add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    obj.add_events_by_kind_and_discussion_id('new_discussion', discussion_ids)
    obj.add_events_by_kind_and_discussion_id('discussion_forked', discussion_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_subscriptions_by_group_id(all_group_ids)
    obj.add_users_by_id
    obj
  end

  def self.for_outcomes(collection, user_id, exclude_types = [])
    obj = new(exclude_types)

    obj.add_outcomes_by_id(collection)
    obj.add_polls_by_id(collection.map(&:poll_id))
    obj.add_users_by_id
    obj
  end

  def self.for_stances(collection, user_id, exclude_types = [])
    obj = new(exclude_types)
    stance_ids = collection.map(&:id)
    poll_ids = collection.map(&:poll_id).uniq.compact
    obj.add_stances_by_id(stance_ids)
    obj.add_polls_by_id(poll_ids)
    obj.add_outcomes_by_poll_id(poll_ids)
    obj.add_poll_options_by_poll_id(poll_ids)
    obj.add_stance_choices_by_stance_id(stance_ids)
    obj.add_events_by_kind_and_poll_id('poll_created', poll_ids)
    obj.add_users_by_id(collection.map(&:participant_id).compact)
    obj
  end

  def add_users_by_id(ids = [])
    scope[:users_by_id] ||= {}
    return if exclude_types.include?('user')
    User.where(id: ids.concat(@user_ids).compact.uniq).each do |user|
      scope[:users_by_id][user.id] = user
    end
  end

  # in controller
  # ScopeService.add_groups_by_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_groups_by_id(group_ids)
    return [] if group_ids.empty?
    return [] if exclude_types.include?('group')
    scope[:groups_by_id] ||= {}
    return [] if group_ids.empty?
    ids = []
    parent_ids = []
    Group.where(id: group_ids).each do |group|
      ids.push group.id
      @user_ids.push group.creator_id
      parent_ids.push group.parent_id if group.parent_id
      scope[:groups_by_id][group.id] = group
    end
    ids.concat add_groups_by_id(parent_ids)
  end

  def add_subscriptions_by_group_id(group_ids)
    return [] if group_ids.empty?
    return [] if exclude_types.include?('subscription')
    scope[:subscriptions_by_group_id] ||=  {}
    Group.includes(:subscription).where(id: group_ids).each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription
    end
  end

  # in controller
  # ScopeService.add_my_memberships_by_group_id(scope, groups.pluck(:parent_id))
  # ScopeService.add_groups_by_id(scope, discussions.pluck(:parent_id))
  def add_memberships_by_group_id(group_ids, user_id)
    scope[:memberships_by_group_id] ||= {}
    return [] if group_ids.empty?
    return [] if exclude_types.include?('membership')
    return [] if user_id.nil?
    ids = []
    Membership.where(group_id: group_ids, user_id: user_id).each do |m|
      ids.push m.id
      @user_ids.push m.user_id
      @user_ids.push m.inviter_id if m.inviter_id
      scope[:memberships_by_group_id][m.group_id] = m
    end
    ids
  end

  def add_memberships_by_id(collection)
    return [] if exclude_types.include?('membership')
    scope[:memberships_by_id] ||= {}
    ids = []
    collection.each do |m|
      ids.push m.id
      @user_ids.push m.user_id
      @user_ids.push m.inviter_id if m.inviter_id
      scope[:memberships_by_id][m.id] = m
    end
    ids
  end

  def add_polls_by_discussion_id(discussion_ids)
    return [] if discussion_ids.empty?
    return [] if exclude_types.include?('poll')
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    ids = []
    Poll.where(discussion_id: discussion_ids).each do |poll|
      ids.push poll.id
      @user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
    ids
  end

  def add_events_by_id(event_ids)
    return [] if event_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_id] ||= {}
    parent_ids = []
    Event.where(id: event_ids).each do |event|
      @user_ids.push event.user_id if event.user_id
      parent_ids.push(event.parent_id) if event.parent_id
      scope[:events_by_id][event.id] = event
    end
    add_events_by_id(parent_ids) if parent_ids.any?
    parent_ids
  end

  def add_comments_by_id(collection = nil, ids: [])
    collection = Comment.where(id: ids) if collection.nil?
    return [] if exclude_types.include?('comment')
    scope[:comments_by_id] ||= {}
    parent_ids = []
    collection.each do |comment|
      @user_ids.push comment.user_id
      scope[:comments_by_id][comment.id] = comment
      parent_ids.push comment.parent_id if comment.parent_id
    end
    add_comments_by_id(ids: parent_ids) if parent_ids.any?
  end

  def add_outcomes_by_poll_id(poll_ids)
    add_outcomes_by_id(Outcome.where(poll_id: poll_ids))
  end

  def add_outcomes_by_id(collection = nil, ids: [])
    return [] if exclude_types.include?('outcome')
    poll_ids = []
    scope[:outcomes_by_id] ||= {}
    scope[:outcomes_by_poll_id] ||= {}
    collection ||= Outcome.where(id: ids)
    collection.each do |outcome|
      @user_ids.push outcome.author_id
      poll_ids.push outcome.poll_id
      scope[:outcomes_by_id][outcome.id] = outcome
      scope[:outcomes_by_poll_id][outcome.poll_id] = outcome if outcome.latest
    end
    poll_ids
  end

  def add_polls_by_id(poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('poll')
    scope[:polls_by_id] ||= {}
    Poll.where(id: poll_ids).each do |poll|
      @user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
    end
  end

  def add_reactions_by_id(ids)
    return [] if ids.empty?
    return [] if exclude_types.include?('reaction')
    scope[:reactions_by_id] ||= {}
    Reaction.where(id: ids).each do |reaction|
      scope[:reactions_by_id][reaction.id] = reaction
    end
  end

  def add_poll_options_by_poll_id(poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('poll_option')
    scope[:poll_options_by_poll_id] ||= {}
    PollOption.where(poll_id: poll_ids).each do |poll_option|
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  def add_stances_by_id(stance_ids)
    return [] if stance_ids.empty?
    return [] if exclude_types.include?('stance')
    scope[:stances_by_id] ||= {}
    scope[:users_by_id] ||= {}
    Stance.where(id: stance_ids).each do |stance|
      @user_ids.push stance.participant_id
      scope[:stances_by_id][stance.id] = stance
    end
    add_stance_choices_by_stance_id(stance_ids)
  end

  def add_stance_choices_by_stance_id(stance_ids)
    return [] if stance_ids.empty?
    return [] if exclude_types.include?('stance_choice')
    scope[:stance_choices_by_stance_id] ||= {}
    StanceChoice.where(stance_id: stance_ids).each do |choice|
      scope[:stance_choices_by_stance_id][choice.stance_id] ||= []
      scope[:stance_choices_by_stance_id][choice.stance_id].push choice
    end
  end

  def add_stances_by_poll_id(poll_ids, user_id)
    scope[:stances_by_id] ||= {}
    scope[:stances_by_poll_id] ||= {}
    return [] if user_id.nil?
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('stance')
    @user_ids.push user_id
    ids = []
    Stance.where(poll_id: poll_ids, participant_id: user_id).each do |stance|
      ids.push stance
      scope[:stances_by_id][stance.id] = stance
      scope[:stances_by_poll_id][stance.poll_id] = stance
    end
    add_stance_choices_by_stance_id(ids)
    ids
  end

  def add_discussion_readers_by_discussion_id(discussion_ids, user_id)
    scope[:discussion_readers_by_discussion_id] ||= {}
    return [] if discussion_ids.empty?
    return [] if user_id.nil?
    # return [] if exclude_types.include?('discussion')
    ids = []
    @user_ids.push user_id
    DiscussionReader.
                     where(discussion_id: discussion_ids, user_id: user_id).each do |dr|
      ids.push dr.id
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
    ids
  end

  def add_events_by_kind_and_discussion_id(kind, discussion_ids)
    return [] if discussion_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_discussion_id] ||= {}
    scope[:events_by_discussion_id][kind] ||= {}
    ids = []
    Event.where(kind: kind, eventable_id: discussion_ids).each do |event|
      @user_ids.push event.user_id
      scope[:events_by_discussion_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_events_by_kind_and_poll_id(kind, poll_ids)
    return [] if poll_ids.empty?
    return [] if exclude_types.include?('event')
    scope[:events_by_poll_id] ||= {}
    scope[:events_by_poll_id][kind] ||= {}
    ids = []
    Event.where(kind: kind, eventable_id: poll_ids).each do |event|
      @user_ids.push event.user_id
      scope[:events_by_poll_id][kind][event.eventable_id] = event
    end
    ids
  end

  def add_discussions_by_id(discussion_ids)
    return [] if discussion_ids.empty?
    scope[:discussions_by_id] ||= {}
    Discussion.where(id: discussion_ids).each do |d|
      @user_ids.push d.author_id
      scope[:discussions_by_id][d.id] = d
    end
  end
end
