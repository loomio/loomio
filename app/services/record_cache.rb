class RecordCache
  attr_accessor :scope
  attr_accessor :exclude_types
  attr_accessor :ids
  attr_accessor :current_user_id

  def initialize
    @scope = {}
    @ids = {}
    @exclude_types = []
    @current_user_id = nil
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
    obj = self.new
    obj.exclude_types = exclude_types
    obj.current_user_id = user_id
    return obj unless item = collection.first

    case item.class
    when Discussion
      collection_ids = collection.map(&:id)
      obj.add_discussion_readers DiscussionReader.where(discussion_id: collection_ids, user_id: user_id)
      obj.add_groups_subscriptions_memberships Group.include(:subscription).where(id: ids_and_parent_ids(collection.map(&:group_id)))
      obj.add_polls_options_stances_choices Poll.active.where(discussion_id: collection_ids)
      obj.add_events(Event.where(kind: 'new_discussion', eventable_id: collection_ids))

    when Reaction
      obj.add_users User.where(id: collection.map(&:user_id))

    when Notification
      obj.add_events_eventables Event.where(id: collection.map(&:event_id))
      obj.add_users User.where(id: collection.map(&:user_id))

    when Group
      obj.add_groups_subscriptions_memberships Group.include(:subscription).where(id: ids_and_parent_ids(collection.map(&:id)))

    when Membership
      obj.add_groups Group.where(id: collection.map(&:group_id))
      obj.add_users User.where(id: collection.map(&:user_id).concat(collection.map(&:inviter_id)).compact.uniq)

    when Poll
      obj.add_polls_options_stances_choices collection

    when Outcome
      obj.add_users(collection.map(&:author_id))

    when Stance
      add_polls
      for_stances(collection, user_id, exclude_types)

    when User
      for_users(collection, user_id, exclude_types)

    when DiscussionReader
      obj.add_user(collection.map(&:user_id))

    when Comment
      obj.add_users User.where(id: collection.map(&:user_id))
    when MembershipRequest
      obj.add_users User.where(id: collection.map(&:requestor_id))
      obj.add_users User.where(id: collection.map(&:responder_id))
    when Document
      obj.add_users User.where(id: collection.map(&:author_id))
    when PaperTrail::Version
      # no cache required
    when Tag
      # no cache required
    when Translation
      # no cache required
    when Event
      for_events(collection, user_id, exclude_types)
    else
      raise "unrecognised item: #{item.class}"
    end
  end

  def self.for_events(collection, user_id, exclude_types = [])
    obj = new(exclude_types)

    ids = {
      events: [],
      discussion: [],
      group: [],
      comment: [],
      stance: [],
      outcome: [],
      poll: [],
      reaction: [],
      membership: []
    }

    collection.each do |e|
      ids[:discussion].push e.discussion_id if e.discussion_id
      ids[e.eventable_type.underscore.to_sym].push e.eventable_id
    end

    ids.keys.each { |key| ids[key] = ids[key].uniq }

    # all event ids.. collection ids and their parent ids
    # @ids[:events].concat collection.map(&:id)
    ids[:events].concat all_parent_ids_for(Event, collection.map(&:id))

    # fetch all comment parents
    ids[:comments].concat all_parent_ids_for(Comment, ids[:comments])

    # find related group ids
    unless exclude_types.include?('group')
      ids[:group].concat Discussion.where(id: ids[:discussion]).pluck(:group_id)
      ids[:group].concat Poll.where(id: ids[:poll]).pluck(:group_id)
      ids[:group].concat all_parent_ids_for(Group, ids[:group])
    end

    obj.ids = ids
    obj.add_polls               Poll.where(id: ids[:poll])
    obj.add_stances             Stance.where(poll_id: ids[:poll], participant_id: user_id, latest: true)
    obj.add_discussions         Discussion.where(id: ids[:discussion])
    obj.add_discussion_readers  DiscussionReader.where(discussion_id: ids[:discussion], user_id: user_id)
    obj.add_events              Event.where(id: ids[:event])
    obj.add_outcomes            Outcome.where(poll_id: ids[:poll])
    obj.add_poll_options        PollOption.where(poll_id: ids[:poll])
    obj.add_groups              Group.where(id: ids[:group])
    obj.add_memberships         Membership.where(group_id: ids[:group], user_id: user_id)
    obj.add_comments            Comment.where(id: ids[:comment])
    obj.add_stances             Stance.where(id: ids[:stance])
    obj.add_reactions           Reaction.where(id: ids[:reaction])
    obj.add_group_subscriptions Group.includes(:subscription).where(id: ids[:group])
    # obj.add_events              Event.where(kind: 'new_discussion', eventable_id: @ids[:discussion])
    # obj.add_events              Event.where(kind: 'discussion_forked', eventable_id: @ids[:discussion])
    # obj.add_events              Event.where(kind: 'poll_created', eventable_id: @ids[:poll])
    obj.add_users               User.where(id: ids[:user])
    obj
  end

  def self.ids_and_parent_ids(klass, ids)
    [ids, all_parent_ids_for(klass,ids)].flatten.uniq
  end

  def self.all_parent_ids_for(klass, ids)
    return [] if ids.empty?
    parent_ids = klass.where(id: ids).pluck(:parent_id)
    [parent_ids, all_parent_ids_for(klass, parent_ids)].flatten.uniq
  end

  # remember to join subscriptions for this call
  def add_groups_subscriptions_memberships(collection)
    return [] if exclude_types.include?('group')
    scope[:groups_by_id] ||= {}
    collection.each do |group|
      @ids[:user].push group.creator_id
      scope[:groups_by_id][group.id] = group
    end
    add_memberships(Membership.where(group_id: group_ids, user_id: current_user_id))
    add_subscriptions(collection)
  end

  # this is a colleciton of groups joined to subscription.. crazy I know
  def add_subscriptions(collection)
    return [] if exclude_types.include?('subscription')
    scope[:subscriptions_by_group_id] ||=  {}
    collection.each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription
    end
  end

  def add_memberships(collection)
    return if exclude_types.include?('membership')
    scope[:memberships_by_group_id] ||= {}
    scope[:memberships_by_id] ||= {}
    collection.each do |m|
      @ids[:user].push m.user_id
      @ids[:user].push m.inviter_id if m.inviter_id
      scope[:memberships_by_group_id][m.group_id] = m
      scope[:memberships_by_id][m.id] = m
    end
  end

  def add_polls_options_stances_choices(collection)
    return if exclude_types.include?('poll')
    collection_ids = collection.map(&:ids)
    add_polls collection
    add_poll_options PollOption.where(poll_id: collection_ids)
    add_stances_and_choices Stance.where(poll_id: collection_ids, participant_id: current_user_id)
  end

  def add_polls(collection)
    return if exclude_types.include?('poll')
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    collection.each do |poll|
      @ids[:user].push poll.author_id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
  end

  def add_comments(collection)
    return [] if exclude_types.include?('comment')
    scope[:comments_by_id] ||= {}
    collection.each do |comment|
      @ids[:user].push comment.user_id
      scope[:comments_by_id][comment.id] = comment
    end
  end

  def add_outcomes(collection)
    return [] if exclude_types.include?('outcome')
    scope[:outcomes_by_id] ||= {}
    scope[:outcomes_by_poll_id] ||= {}
    collection.each do |outcome|
      @ids[:user].push outcome.author_id
      scope[:outcomes_by_id][outcome.id] = outcome
      scope[:outcomes_by_poll_id][outcome.poll_id] = outcome if outcome.latest
    end
  end

  def add_reactions(collection)
    return [] if ids.empty?
    return [] if exclude_types.include?('reaction')
    scope[:reactions_by_id] ||= {}
    Reaction.where(id: ids).each do |reaction|
      scope[:reactions_by_id][reaction.id] = reaction
    end
  end

  def add_poll_options(collection)
    return [] if exclude_types.include?('poll_option')
    scope[:poll_options_by_poll_id] ||= {}
    collection.each do |poll_option|
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  def add_stances_and_choices(collection)
    return if exclude_types.include?('stance')
    add_stances collection
    add_stance_choices StanceChoice.where(stance_id: collection.map(&:id))
  end

  def add_stances(collection)
    return [] if exclude_types.include?('stance')
    scope[:stances_by_id] ||= {}
    scope[:stances_by_poll_id] ||= {}
    collection.each do |stance|
      @ids[:user] = stance.participant_id
      scope[:stances_by_id][stance.id] = stance
      scope[:stances_by_poll_id][stance.poll_id] = stance
    end
  end

  def add_stance_choices(collection)
    return [] if exclude_types.include?('stance_choice')
    scope[:stance_choices_by_stance_id] ||= {}
    collection.each do |choice|
      scope[:stance_choices_by_stance_id][choice.stance_id] ||= []
      scope[:stance_choices_by_stance_id][choice.stance_id].push choice
    end
  end

  def add_discussion_readers(collection)
    return [] if exclude_types.include?('discussion_reader')
    scope[:discussion_readers_by_discussion_id] ||= {}
    collection.each do |dr|
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
  end

  def add_events(collection)
    return [] if exclude_types.include?('event')
    scope[:events_by_id] ||= {}
    scope[:events_by_kind_and_eventable_id] ||= {}

    collection.each do |event|
      @ids[:user].push event.user_id if event.user_id
      scope[:events_by_id][event.id] = event
      scope[:events_by_kind_and_eventable_id][kind] ||= {}
      scope[:events_by_kind_and_eventable_id][kind][event.eventable_id] = event
    end
  end

  def add_events_eventables(collection)
    events = collection.includes(:eventable)
    add_events(events)
    add_eventables(events.map(&:eventable))
  end

  def add_eventables(collection)
    collection.each do |eventable|
      scope["#{eventable.class.underscore.pluarize}_by_id"][eventable.id] = eventable
    end
  end

  def add_discussions_discussion_readers(collection)
    add_discussions(collection)
    add_discussion_readers(DiscussionReader.where(discussion_id: collection.map(&:id), user_id: current_user_id))
  end

  def add_discussions(collection)
    return [] if discussion_ids.empty?
    scope[:discussions_by_id] ||= {}
    collection.each do |discussion|
      @ids[:user].push discussion.author_id
      scope[:discussions_by_id][discussion.id] = discussion
    end
  end
end
