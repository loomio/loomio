class RecordCache
  KNOWN_MISSING_KEYS = %i[
    memberships_by_group_id
    outcomes_by_poll_id
    topic_readers_by_topic_id
  ].freeze

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

  # if we've already queried for a record and it does not exist, then we stil add a key into the hash, with nil
  # so you can safely provide a query to check, without it being run redundandly.
  # this is most important for discussion_readers
  # so it's used in two ways:
  # fetch(keys, id) { query if record maybe not cached }
  # or
  # fetch(keys, id) || query/action if result is nil
  def fetch(key_or_keys, id)
    keys = Array(key_or_keys)
    cache = scope.dig(*keys) || {}

    return cache[id] if cache.has_key?(id)
    return nil unless block_given?

    ActiveSupport::Notifications.instrument('record_cache.fallback', keys: keys, id: id) do
      yield
    end
  end

  def self.for_collection(collection, user_id, exclude_types = [])
    obj = self.new
    obj.exclude_types = exclude_types
    obj.current_user_id = user_id

    records = collection.to_a
    return obj if records.empty?

    case records.first.class.to_s
    when 'Translation'
      obj.merge_index(:translations_by_id, records)

    when 'Topic'
      topic_ids = records.map(&:id)
      discussion_topics = records.select { |t| t.topicable_type == 'Discussion' }
      poll_topics = records.select { |t| t.topicable_type == 'Poll' }
      discussion_ids = discussion_topics.map(&:topicable_id)
      poll_ids = poll_topics.map(&:topicable_id)
      obj.add_topics(records)
      obj.add_topic_readers(TopicReader.where(topic_id: topic_ids, user_id: obj.current_user_id), topic_ids: topic_ids)
      if discussion_ids.any?
        discussions = discussion_topics.map(&:topicable).compact
        obj.add_discussions(discussions)
        obj.add_reactions_for_eventables(discussions)
      end
      if poll_ids.any?
        polls = Poll.where(id: poll_ids)
        obj.add_polls_options_stances_outcomes(polls)
        obj.add_reactions_for_eventables(polls)
      end
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, records.map(&:group_id).compact))

    when 'Discussion'
      topic_ids = records.map(&:topic_id)
      obj.add_discussions(records)
      obj.add_topics(Topic.where(id: topic_ids))
      obj.add_topic_readers(TopicReader.where(topic_id: topic_ids, user_id: obj.current_user_id), topic_ids: topic_ids)
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, records.map(&:group_id).compact))
      obj.add_polls_options_stances_outcomes Poll.active.where(topic_id: topic_ids)
      obj.add_reactions_for_eventables(records)

    when 'Reaction'
      obj.add_reactions(records)

    when 'Notification'
      obj.add_events_complete Event.includes(:eventable, :topic).where(id: records.map(&:event_id))
      obj.user_ids.concat records.map(&:user_id)

    when 'Group'
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, records.map(&:id)))

    when 'Membership'
      obj.add_groups Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, records.map(&:group_id)))
      obj.user_ids.concat records.map(&:user_id).concat(records.map(&:inviter_id).compact).compact.uniq

    when 'Poll'
      topic_ids = records.map(&:topic_id)
      obj.add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: ids_and_parent_ids(Group, records.map(&:group_id)))
      obj.add_topics(Topic.where(id: topic_ids))
      obj.add_topic_readers(TopicReader.where(topic_id: topic_ids, user_id: obj.current_user_id), topic_ids: topic_ids)
      obj.add_discussions(Discussion.where(topic_id: topic_ids))
      obj.add_polls_options_stances_outcomes records
      obj.add_reactions_for_eventables(records)
      obj.add_inline_translations

    when 'Outcome'
      obj.add_polls Poll.where(id: records.map(&:poll_id))
      obj.user_ids.concat records.map(&:author_id)
      obj.add_reactions_for_eventables(records)

    when 'Stance'
      obj.add_stances(records)
      obj.add_polls_options_stances_outcomes Poll.kept.where(id: records.map(&:poll_id))
      obj.add_reactions_for_eventables(records)

    when 'User'
      # do nothing

    when 'TopicReader', 'DiscussionReader'
      obj.user_ids.concat records.map(&:user_id)

    when 'Comment'
      obj.add_comments(records)
      obj.add_reactions_for_eventables(records)

    when 'MembershipRequest'
      obj.user_ids.concat records.map(&:requestor_id).concat(records.map(&:responder_id)).compact.uniq

    when 'SearchResult'
      obj.user_ids.concat records.map(&:author_id).compact
      obj.add_polls_options_stances_outcomes Poll.kept.where(id: records.map(&:poll_id))

    when 'Event'
      obj.add_events_complete(records)
    end

    obj.add_users User.with_attached_uploaded_avatar.where(id: obj.user_ids.compact.uniq)
    obj.add_tags_complete
    obj.add_inline_translations
    obj
  end

  def merge_index(key, collection)
    scope[key] ||= {}
    scope[key].merge!(collection.index_by(&:id))
  end

  def add_known_missing(key, ids)
    unless KNOWN_MISSING_KEYS.include?(key.to_sym)
      raise ArgumentError, "#{key} is not a known-missing cache key"
    end

    scope[key] ||= {}
    ids.compact.each { |id| scope[key][id] = nil }
  end

  def add_events_complete(collection)
    events = Event.includes(:eventable, :topic).where(id: collection.map(&:id))
    topics = events.map(&:topic).compact.uniq
    eventables = events.map(&:eventable).compact.uniq
    topic_readers = TopicReader.where(topic_id: topics.map(&:id), user_id: current_user_id)
    poll_ids = poll_ids_from_eventables(eventables)
    group_ids = topics.map(&:group_id).compact.uniq

    user_ids.concat events.map(&:user_id).compact
    add_events(events)
    add_eventables(eventables)
    add_topics(topics)
    add_topic_readers(topic_readers, topic_ids: topics.map(&:id))
    add_polls_options_stances_outcomes(Poll.where(id: poll_ids)) if poll_ids.any?
    add_reactions_for_eventables(eventables)
    add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: group_ids)
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

  def add_eventables(collection)
    collection.each do |eventable|
      @user_ids.push eventable.user_id if eventable.respond_to?(:user_id)
      scope["#{eventable.class.to_s.underscore.pluralize}_by_id"] ||= {}
      scope["#{eventable.class.to_s.underscore.pluralize}_by_id"][eventable.id] = eventable
    end
  end

  def add_reactions_for_eventables(collection)
    return [] if exclude_types.include?('reaction')

    reactables = collection.flat_map do |eventable|
      eventable.is_a?(Reaction) ? eventable.reactable : eventable
    end.compact.select { |eventable| eventable.respond_to?(:reactions) }.uniq

    scope[:reactions_by_reactable_type_and_id] ||= {}
    reactables.each do |reactable|
      scope[:reactions_by_reactable_type_and_id][reactable.class.to_s] ||= {}
      scope[:reactions_by_reactable_type_and_id][reactable.class.to_s][reactable.id] = []
    end

    reaction_query_for_eventables(reactables).includes(:user).each do |reaction|
      add_reaction(reaction)
    end
  end

  def reaction_query_for_eventables(collection)
    relations = collection.group_by { |eventable| eventable.class.to_s }.map do |reactable_type, eventables|
      Reaction.where(reactable_type: reactable_type, reactable_id: eventables.map(&:id))
    end

    relations.reduce { |relation, next_relation| relation.or(next_relation) } || Reaction.none
  end

  def poll_ids_from_eventables(collection)
    collection.filter_map { |eventable| poll_id_for_eventable(eventable) }.uniq
  end

  def poll_id_for_eventable(eventable)
    case eventable
    when Poll
      eventable.id
    when Stance, Outcome, PollOption
      eventable.poll_id
    when Reaction
      poll_id_for_eventable(eventable.reactable)
    end
  end

  def self.ids_and_parent_ids(klass, ids)
    [ids, all_parent_ids_for(klass, ids)].flatten.compact.uniq
  end

  def self.all_parent_ids_for(klass, ids)
    ids = Array(ids).compact.uniq
    return [] if ids.empty?

    parent_ids = klass.where(id: ids).pluck(:parent_id).compact.uniq
    [parent_ids, all_parent_ids_for(klass, parent_ids)].flatten.compact.uniq
  end

  # remember to join subscriptions for this call
  def add_groups_subscriptions_memberships(collection)
    return [] if exclude_types.include?('group')
    add_groups collection
    add_memberships Membership.active.where(group_id: group_ids, user_id: current_user_id)
    add_subscriptions collection
  end

  def add_groups(collection)
    return [] if exclude_types.include?('group')
    @user_ids.concat collection.map(&:creator_id)
    merge_index(:groups_by_id, collection)
  end

  # this is a colleciton of groups joined to subscription.. crazy I know
  def add_subscriptions(collection)
    return [] if exclude_types.include?('subscription')
    scope[:subscriptions_by_group_id] ||=  {}
    collection.each do |group|
      scope[:subscriptions_by_group_id][group.id] = group.subscription || Subscription.new
    end
  end

  def add_memberships(collection)
    return if exclude_types.include?('membership')
    scope[:memberships_by_group_id] ||= {}
    scope[:memberships_by_id] ||= {}

    add_known_missing(:memberships_by_group_id, group_ids)

    collection.each do |m|
      @user_ids.push m.user_id
      @user_ids.push m.inviter_id if m.inviter_id
      scope[:memberships_by_group_id][m.group_id] = m
      scope[:memberships_by_id][m.id] = m
    end
  end

  def add_polls_options_stances_outcomes(collection)
    return if exclude_types.include?('poll')
    collection_ids = collection.map(&:id)
    add_polls collection
    add_poll_options PollOption.where(poll_id: collection_ids)
    add_stances Stance.latest.where(poll_id: collection_ids, participant_id: current_user_id)
    add_outcomes(Outcome.latest.where(poll_id: collection_ids), poll_ids: collection_ids)
  end

  def add_polls(collection)
    return if exclude_types.include?('poll')
    scope[:polls_by_topic_id] ||= {}
    scope[:polls_by_id] ||= {}
    collection.each do |poll|
      @user_ids.push poll.author_id
      scope[:polls_by_id][poll.id] = poll
      scope[:polls_by_topic_id][poll.topic_id] ||= []
      scope[:polls_by_topic_id][poll.topic_id].push poll
    end
  end

  def add_comments(collection)
    return [] if exclude_types.include?('comment')
    @user_ids.concat collection.map(&:user_id)
    merge_index(:comments_by_id, collection)
  end

  def add_tags_complete
    scope[:tags_by_type_and_id] ||= {}

    scope.fetch(:topics_by_id, {}).each_value do |topic|
      scope[:tags_by_type_and_id]['Topic'] ||= {}
      scope[:tags_by_type_and_id]['Topic'][topic.id] = topic.tags || []
    end

    group_ids.each do |group_id|
      scope[:tags_by_type_and_id]['Group'] ||= {}
      scope[:tags_by_type_and_id]['Group'][group_id] = []
    end

    Tag.where(group_id: group_ids).each do |tag|
      scope[:tags_by_type_and_id]['Group'][tag.group_id] ||= []
      scope[:tags_by_type_and_id]['Group'][tag.group_id].push tag
    end
  end

  def add_outcomes(collection, options = {})
    return [] if exclude_types.include?('outcome')
    @user_ids.concat collection.map(&:author_id)
    merge_index(:outcomes_by_id, collection)
    scope[:outcomes_by_poll_id] ||= {}
    add_known_missing(:outcomes_by_poll_id, options.fetch(:poll_ids, []))
    scope[:outcomes_by_poll_id].merge!(collection.select(&:latest).index_by(&:poll_id))
    add_reactions_for_eventables(collection)
  end

  def add_reactions(collection)
    return [] if collection.empty?
    return [] if exclude_types.include?('reaction')

    collection.each { |reaction| add_reaction(reaction) }
  end

  def add_reaction(reaction)
    @user_ids.push reaction.user_id
    scope[:reactions_by_id] ||= {}
    scope[:reactions_by_id][reaction.id] = reaction
    scope[:reactions_by_reactable_type_and_id] ||= {}
    scope[:reactions_by_reactable_type_and_id][reaction.reactable_type] ||= {}
    scope[:reactions_by_reactable_type_and_id][reaction.reactable_type][reaction.reactable_id] ||= []
    reactions = scope[:reactions_by_reactable_type_and_id][reaction.reactable_type][reaction.reactable_id]
    reactions.push(reaction) unless reactions.any? { |cached| cached.id == reaction.id }
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
    add_reactions_for_eventables(collection)
  end


  def add_inline_translations
    return unless TranslationService.available?
    return if exclude_types.include?('translation')
    user = scope.dig(:users_by_id, current_user_id) || User.find_by(id: current_user_id)
    return unless user && user.auto_translate

    locale = TranslationService.locale_for_google(user.locale)
    return if locale.blank?

    {
      'Group' =>  scope.fetch(:groups_by_id, {}).keys,
      'Discussion' =>  scope.fetch(:discussions_by_id, {}).keys,
      'Poll' => scope.fetch(:polls_by_id, {}).keys
    }.each_pair do |type, ids|
      Translation.where(language: locale,
                        translatable_type: type,
                        translatable_id: ids).each do |tr|
        scope[:translations_by_type_and_id] ||= {}
        scope[:translations_by_type_and_id][type] ||= {}
        scope[:translations_by_type_and_id][type][tr.translatable_id] = tr
      end
    end
  end

  def add_topics(collection)
    return if exclude_types.include?('topic')
    merge_index(:topics_by_id, collection)
  end

  def add_discussions(collection)
    return if exclude_types.include?('discussion')
    @user_ids.concat collection.map(&:author_id)
    merge_index(:discussions_by_id, collection)
    add_reactions_for_eventables(collection)
  end

  def add_topic_readers(collection, options = {})
    return if exclude_types.include?('topic_reader')
    scope[:topic_readers_by_topic_id] ||= {}
    add_known_missing(:topic_readers_by_topic_id, options.fetch(:topic_ids, []))
    scope[:topic_readers_by_topic_id].merge!(collection.index_by(&:topic_id))
  end

  def add_users(collection)
    return if exclude_types.include?('user')
    merge_index(:users_by_id, collection)
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
