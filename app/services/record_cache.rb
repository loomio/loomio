class RecordCache
  require_relative 'record_cache/loader'
  require_relative 'record_cache/loaders'

  KNOWN_MISSING_KEYS = %i[
    memberships_by_group_id
    outcomes_by_poll_id
    topic_readers_by_topic_id
    undecided_voter_ids_by_poll_id
  ].freeze

  LOADERS = {
    'Translation' => Loaders::Translation,
    'Topic' => Loaders::Topic,
    'Discussion' => Loaders::Discussion,
    'Reaction' => Loaders::Reaction,
    'Notification' => Loaders::Notification,
    'Group' => Loaders::Group,
    'Membership' => Loaders::Membership,
    'Poll' => Loaders::Poll,
    'Outcome' => Loaders::Outcome,
    'Stance' => Loaders::Stance,
    'User' => Loaders::User,
    'TopicReader' => Loaders::Reader,
    'DiscussionReader' => Loaders::Reader,
    'Comment' => Loaders::Comment,
    'MembershipRequest' => Loaders::MembershipRequest,
    'SearchResult' => Loaders::SearchResult,
    'TopicItem' => Loaders::TopicItem
  }.freeze

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

    loader = loader_for(records.first)
    loader.new(cache: obj, records: records).load

    obj.add_users User.with_attached_uploaded_avatar.where(id: obj.user_ids.compact.uniq)
    obj.add_tags_complete
    obj.add_inline_translations
    obj
  end

  def self.loader_for(record)
    record.class.ancestors.filter_map { |ancestor| LOADERS[ancestor.to_s] }.first || Loaders::Noop
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

  def add_topic_items_complete(collection)
    topic_items = TopicItem.includes(:itemable, :topic).where(id: collection.map(&:id))
    topics = topic_items.map(&:topic).compact.uniq
    itemables = topic_items.map(&:itemable).compact.uniq

    unless exclude_types.include?('reaction')
      reactions = itemables.select { |e| e.is_a?(Reaction) }
      if reactions.any?
        ActiveRecord::Associations::Preloader.new(records: reactions, associations: :reactable).call
        add_itemables(reactions.map(&:reactable).compact)
      end
    end

    topic_readers = TopicReader.where(topic_id: topics.map(&:id), user_id: current_user_id)
    poll_ids = poll_ids_from_itemables(itemables)
    group_ids = topics.map(&:group_id).compact.uniq

    user_ids.concat topic_items.map(&:user_id).compact
    add_topic_items(topic_items)
    add_itemables(itemables)
    add_topics(topics)
    add_topic_readers(topic_readers, topic_ids: topics.map(&:id))
    add_polls_options_stances_outcomes(Poll.where(id: poll_ids)) if poll_ids.any?
    add_reactions_for_itemables(itemables)
    add_groups_subscriptions_memberships Group.with_attached_logo.with_attached_cover_photo.includes(:subscription).where(id: group_ids)
  end

  def add_topic_items(collection)
    return [] if exclude_types.include?('topic_item')
    scope[:topic_items_by_id] ||= {}
    scope[:topic_items_by_kind_and_itemable_id] ||= {}

    collection.each do |topic_item|
      @user_ids.push topic_item.user_id if topic_item.user_id
      scope[:topic_items_by_id][topic_item.id] = topic_item
      scope[:topic_items_by_kind_and_itemable_id][topic_item.kind] ||= {}
      scope[:topic_items_by_kind_and_itemable_id][topic_item.kind][topic_item.itemable_id] = topic_item
    end
  end

  def add_itemables(collection)
    collection.each do |itemable|
      @user_ids.push itemable.user_id if itemable.respond_to?(:user_id)
      scope["#{itemable.class.to_s.underscore.pluralize}_by_id"] ||= {}
      scope["#{itemable.class.to_s.underscore.pluralize}_by_id"][itemable.id] = itemable
    end
  end

  def poll_ids_from_itemables(collection)
    collection.filter_map { |itemable| poll_id_for_itemable(itemable) }.uniq
  end

  def poll_id_for_itemable(itemable)
    case itemable
    when Poll
      itemable.id
    when Stance, Outcome, PollOption
      itemable.poll_id
    when Reaction
      poll_id_for_itemable(itemable.reactable)
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
    collection = collection.to_a
    collection_ids = collection.map(&:id)
    add_polls collection
    add_poll_options PollOption.where(poll_id: collection_ids)
    add_stances Stance.latest.where(poll_id: collection_ids, participant_id: current_user_id)
    add_outcomes(Outcome.latest.where(poll_id: collection_ids), poll_ids: collection_ids)
    add_undecided_voter_ids(collection)
  end

  def add_undecided_voter_ids(polls)
    poll_ids = polls.reject(&:detached_anonymous?).select(&:results_include_undecided).map(&:id)
    scope[:undecided_voter_ids_by_poll_id] ||= {}
    add_known_missing(:undecided_voter_ids_by_poll_id, polls.map(&:id))

    Stance.latest.undecided.where(poll_id: poll_ids).pluck(:poll_id, :participant_id).each do |poll_id, participant_id|
      scope[:undecided_voter_ids_by_poll_id][poll_id] ||= []
      scope[:undecided_voter_ids_by_poll_id][poll_id] << participant_id
    end
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
    add_reactions_for_itemables(collection)
  end

  def add_reactions_for_itemables(collection)
    return [] if exclude_types.include?('reaction')

    reactables = collection.flat_map do |itemable|
      itemable.is_a?(Reaction) ? itemable.reactable : itemable
    end.compact.select { |itemable| itemable.respond_to?(:reactions) }.uniq

    scope[:reactions_by_reactable_type_and_id] ||= {}
    reactables.each do |reactable|
      scope[:reactions_by_reactable_type_and_id][reactable.class.to_s] ||= {}
      scope[:reactions_by_reactable_type_and_id][reactable.class.to_s][reactable.id] = []
    end

    reaction_query_for_itemables(reactables).includes(:user).each do |reaction|
      add_reaction(reaction)
    end
  end

  def reaction_query_for_itemables(collection)
    relations = collection.group_by { |itemable| itemable.class.to_s }.map do |reactable_type, itemables|
      Reaction.where(reactable_type: reactable_type, reactable_id: itemables.map(&:id))
    end

    relations.reduce { |relation, next_relation| relation.or(next_relation) } || Reaction.none
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
    add_reactions_for_itemables(collection)
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
    add_reactions_for_itemables(collection)
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
