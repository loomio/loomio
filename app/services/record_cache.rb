class RecordCache
  attr_accessor :scope
  attr_accessor :exclude_types
  attr_accessor :user_ids
  attr_accessor :current_user_id

  def initialize
    @scope = {}.with_indifferent_access
    @user_ids = []
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
    return obj unless item = collection.to_a.first

    # puts "when #{item.class.to_s}"
    case item.class.to_s
    when 'Discussion'
      collection_ids = collection.map(&:id)
      obj.add_discussions(collection)
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, collection.map(&:group_id).compact))
      obj.add_polls_options_stances_outcomes Poll.active.where(discussion_id: collection_ids)

    when 'Reaction'
      obj.user_ids.concat collection.map(&:user_id)

    when 'Notification'
      obj.add_events_complete Event.includes(:eventable).where(id: collection.map(&:event_id))
      # obj.add_events_eventables Event.includes(:eventable).where(id: collection.map(&:event_id))
      obj.user_ids.concat collection.map(&:user_id)

    when 'Group'
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, collection.map(&:id)))

    when 'Membership'
      obj.add_groups Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, collection.map(&:group_id)))
      obj.user_ids.concat collection.map(&:user_id).concat(collection.map(&:inviter_id).compact).compact.uniq

    when 'Poll'
      obj.add_groups Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, collection.map(&:group_id)))
      obj.add_discussions(Discussion.where(id: collection.map(&:discussion_id).uniq.compact))
      obj.add_polls_options_stances_outcomes collection

    when 'Outcome'
      obj.add_polls Poll.where(id: collection.map(&:poll_id))
      obj.user_ids.concat collection.map(&:author_id)

    when 'Stance'
      obj.add_stances(collection)
      obj.add_polls_options_stances_outcomes Poll.kept.where(id: collection.map(&:poll_id))

    when 'User'
      # do nothing

    when 'DiscussionReader'
      obj.user_ids.concat collection.map(&:user_id)

    when 'Comment'
      obj.user_ids.concat collection.map(&:user_id)

    when 'MembershipRequest'
      obj.user_ids.concat collection.map(&:requestor_id).concat(collection.map(&:responder_id)).compact.uniq

    when 'Document'
      obj.user_ids.concat collection.map(&:author_id).compact

    when 'SearchResult'
      obj.user_ids.concat collection.map(&:author_id).compact
      obj.add_polls_options_stances_outcomes Poll.kept.where(id: collection.map(&:poll_id))

    else
      obj.add_events_complete(collection) if item.is_a?(Event)
    end

    obj.add_users User.with_attached_uploaded_avatar.where(id: obj.user_ids)
    obj.add_discussion_readers(DiscussionReader.where(discussion_id: obj.discussion_ids, user_id: user_id))
    obj.add_events Event.where(kind: 'new_discussion', eventable_id: obj.discussion_ids)
    obj.add_events Event.where(kind: 'discussion_forked', eventable_id: obj.discussion_ids)
    obj.add_events Event.where(kind: 'poll_created', eventable_id: obj.poll_ids)
    obj.add_tags_complete
    obj
  end

  def add_events_complete(collection)
    ids = {discussion: [], comment: [], group: [], poll: []}.with_indifferent_access


    Event.includes(:eventable).where(id: collection.map(&:id)).each do |e|
      ids[:discussion].push e.discussion_id if e.discussion_id
      next unless e.eventable
      ids[e.eventable_type.underscore] ||= []
      ids[e.eventable_type.underscore].push e.eventable_id
      if ['Stance', 'Outcome', 'PollOption'].include? e.eventable_type
        ids[:poll].push e.eventable.poll_id
      end
    end

    ids.keys.each { |key| ids[key] = ids[key].uniq }

    # Eventable specific stuff
    # comments
    # ids[:comment].concat self.class.all_parent_ids_for(Comment, ids[:comment]) if ids[:comment].any?


    # find related group ids
    unless exclude_types.include?('group')
      ids[:group].concat Discussion.where(id: ids[:discussion]).pluck(:group_id)
      ids[:group].concat Poll.where(id: ids[:poll]).pluck(:group_id)
      # ids[:group].concat all_parent_ids_for(Group, ids[:group])
    end

    add_polls_options_stances_outcomes Poll.where(id: ids[:poll])
    add_discussions Discussion.where(id: ids[:discussion])

    add_events_eventables   Event.includes(:eventable).where(id: self.class.ids_and_parent_ids(Event, collection.map(&:id)))
    add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids[:group])
    add_comments            Comment.where(id: ids[:comment])
    # obj.add_reactions           Reaction.where(id: ids[:reaction])
    # obj.add_group_subscriptions Group.includes(:subscription).where(id: ids[:group])
    # obj.add_events              Event.where(kind: 'discussion_forked', eventable_id: @ids[:discussion])
    # obj.add_events              Event.where(kind: 'poll_created', eventable_id: @ids[:poll])
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
    group_ids = add_groups(collection)
    add_memberships(Membership.where(group_id: group_ids, user_id: current_user_id), group_ids)
    add_subscriptions(collection)
  end

  def add_groups(collection)
    return [] if exclude_types.include?('group')
    scope[:groups_by_id] ||= {}
    collection.map do |group|
      @user_ids.push group.creator_id
      scope[:groups_by_id][group.id] = group
      group.id
    end
  end

  # this is a colleciton of groups joined to subscription.. crazy I know
  def add_subscriptions(collection)
    return [] if exclude_types.include?('subscription')
    scope[:subscriptions_by_group_id] ||=  {}
    collection.each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription if group.subscription
    end
  end

  def add_memberships(collection, group_ids)
    return if exclude_types.include?('membership')
    scope[:memberships_by_group_id] ||= {}
    scope[:memberships_by_id] ||= {}
    collection.each do |m|
      @user_ids.push m.user_id
      @user_ids.push m.inviter_id if m.inviter_id
      scope[:memberships_by_group_id][m.group_id] = m
      scope[:memberships_by_id][m.id] = m
    end

    # is this buggy?
    # our cache.fetch method benefits from knowing it is nil
    # group_ids.each do |id|
    #   next if scope[:memberships_by_group_id].has_key?(id)
    #   scope[:memberships_by_group_id][id] = nil
    # end
  end

  def add_polls_options_stances_outcomes(collection)
    return if exclude_types.include?('poll')
    collection_ids = collection.map(&:id)
    add_polls collection
    add_poll_options PollOption.where(poll_id: collection_ids)
    add_stances Stance.latest.where(poll_id: collection_ids, participant_id: current_user_id)
    add_outcomes Outcome.latest.where(poll_id: collection_ids)
  end

  def add_polls(collection)
    return if exclude_types.include?('poll')
    scope[:polls_by_discussion_id] ||= {}
    scope[:polls_by_id] ||= {}
    collection.each do |poll|
      @user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_discussion_id][poll.discussion_id] ||= []
      scope[:polls_by_discussion_id][poll.discussion_id].push poll
    end
  end

  def add_comments(collection)
    return [] if exclude_types.include?('comment')
    scope[:comments_by_id] ||= {}
    collection.each do |comment|
      @user_ids.push comment.user_id
      scope[:comments_by_id][comment.id] = comment
    end
  end

  def add_tags_complete
    scope[:tags_by_type_and_id] ||= {}

    Tag.where(group_id: group_ids).each do |tag|
        scope[:tags_by_type_and_id]['Group'] ||= {}
        scope[:tags_by_type_and_id]['Group'][tag.group_id] ||= []
        scope[:tags_by_type_and_id]['Group'][tag.group_id].push tag
    end
  end

  def add_outcomes(collection)
    return [] if exclude_types.include?('outcome')
    scope[:outcomes_by_id] ||= {}
    scope[:outcomes_by_poll_id] ||= {}
    collection.each do |outcome|
      @user_ids.push outcome.author_id
      scope[:outcomes_by_id][outcome.id] = outcome
      scope[:outcomes_by_poll_id][outcome.poll_id] = outcome if outcome.latest
    end
  end

  def add_reactions(collection)
    return [] if ids.empty?
    return [] if exclude_types.include?('reaction')
    scope[:reactions_by_id] ||= {}
    collection.each do |reaction|
      @user_ids.push reaction.user_id
      scope[:reactions_by_id][reaction.id] = reaction
    end
  end

  def add_poll_options(collection)
    return [] if exclude_types.include?('poll_option')
    scope[:poll_options_by_id] ||= {}
    scope[:poll_options_by_poll_id] ||= {}
    collection.each do |poll_option|
      scope[:poll_options_by_id][poll_option.id] = poll_option
      scope[:poll_options_by_poll_id][poll_option.poll_id] ||= []
      scope[:poll_options_by_poll_id][poll_option.poll_id].push(poll_option)
    end
  end

  def add_stances(collection)
    return [] if exclude_types.include?('stance')
    scope[:stances_by_id] ||= {}
    scope[:my_stances_by_poll_id] ||= {}
    collection.each do |stance|
      @user_ids.push stance.participant_id
      scope[:stances_by_id][stance.id] = stance
      if stance.participant_id == current_user_id && stance.revoked_at.nil?
        scope[:my_stances_by_poll_id][stance.poll_id] = stance 
      end
    end
  end

  def add_events(collection)
    return [] if exclude_types.include?('event')
    scope[:events_by_id] ||= {}
    scope[:events_by_kind_and_eventable_id] ||= {}

    collection.each do |event|
      @user_ids.push event.user_id if event.user_id
      scope[:events_by_id][event.id] = event
      scope[:events_by_kind_and_eventable_id][event.kind] ||= {}
      scope[:events_by_kind_and_eventable_id][event.kind][event.eventable_id] = event
    end
  end

  def add_events_eventables(collection)
    events = collection.includes(:eventable)
    add_events(events)
    add_eventables(events.map(&:eventable).compact)
  end

  def add_eventables(collection)
    collection.each do |eventable|
      @user_ids.push eventable.user_id if eventable.user_id
      scope["#{eventable.class.to_s.underscore.pluralize}_by_id"] ||= {}
      scope["#{eventable.class.to_s.underscore.pluralize}_by_id"][eventable.id] = eventable
    end
  end

  def add_discussions(collection)
    return if exclude_types.include?('discussion')
    scope[:discussions_by_id] ||= {}
    collection.each do |discussion|
      @user_ids.push discussion.author_id
      scope[:discussions_by_id][discussion.id] = discussion
    end
  end

  def add_discussion_readers(collection)
    return if exclude_types.include?('discussion_reader')
    scope[:discussion_readers_by_discussion_id] ||= {}
    collection.each do |dr|
      scope[:discussion_readers_by_discussion_id][dr.discussion_id] = dr
    end
  end

  def add_users(collection)
    return if exclude_types.include?('user')
    scope[:users_by_id] ||= {}
    collection.each do |user|
      scope[:users_by_id][user.id] = user
    end
  end

  def group_ids
    scope.fetch(:groups_by_id, {}).keys
  end

  def discussion_ids
    scope.fetch(:discussions_by_id, {}).keys
  end

  def poll_ids
    scope.fetch(:polls_by_id, {}).keys
  end
end
