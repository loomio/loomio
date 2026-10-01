class RecordCloner
  # Columns not copied from the source record. Every other column is copied,
  # so a new column is cloned by default. Blocked: identity and secrets,
  # foreign keys the cloner points at cloned records, and counters and caches
  # that are recalculated after cloning.
  BLOCKED_COLUMNS = {
    Group => %w[
      id key token parent_id creator_id subscription_id full_name info attachments
      admin_memberships_count closed_polls_count delegates_count discussion_templates_count
      discussions_count memberships_count org_members_count pending_memberships_count
      poll_templates_count polls_count subgroups_count
    ],
    Discussion => %w[id key topic_id attachments versions_count],
    Topic => %w[
      id group_id topicable_id topicable_type ranges_string
      active_polls_count anonymous_polls_count closed_polls_count items_count members_count seen_by_count
    ],
    Poll => %w[
      id key topic_id attachments versions_count
      voters_count undecided_voters_count none_of_the_above_count stance_counts
    ],
    PollOption => %w[id poll_id],
    Stance => %w[id poll_id token attachments versions_count option_scores],
    StanceChoice => %w[id stance_id poll_option_id],
    Outcome => %w[id poll_id poll_option_id attachments versions_count],
    TopicItem => %w[id topic_id itemable_id itemable_type itemable_version_id parent_id],
    Membership => %w[id group_id token],
    Comment => %w[id parent_id parent_type attachments versions_count],
    Tag => %w[id group_id taggings_count used_group_ids]
  }.freeze

  def initialize(recorded_at:)
    @recorded_at = recorded_at
    @cache = {}
  end

  def update_tag_colors(clone_group, group)
    group.tags.pluck(:name, :color).each do |pair|
      Tag.where(group_id: clone_group.id, name: pair[0]).update_all(color: pair[1])
    end
  end

  def create_clone_group_for_actor(group, actor)
    # we don't really use this one except for testing

    clone_group = new_clone_group(group)
    clone_group.creator = actor
    clone_group.subscription = Subscription.new(plan: 'demo', owner: actor)
    clone_group.save!
    save_cloned_content!(clone_group)

    update_tag_colors(clone_group, group)
    clone_reactions!(group)
    store_source_record_ids(clone_group)


    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each { |s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| TopicService.repair(d.topic_id) }
    clone_group.add_member! actor
    clone_group.reload
  end

  def store_source_record_ids(clone_group)
    source_ids = {}
    @cache.each_pair do |key, value|
      class_name, id = key.split('-')
      source_ids["#{class_name}-#{value.id}"] = id.to_i
    end
    clone_group.info['source_record_ids'] = source_ids
    clone_group.save!
  end


  def create_clone_group(group)
    clone_group = new_clone_group(group)
    clone_group.save!
    save_cloned_content!(clone_group)

    update_tag_colors(clone_group, group)
    clone_reactions!(group)

    store_source_record_ids(clone_group)

    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| TopicService.repair(d.topic_id) }
    clone_group.reload
    clone_group
  end

  def clone_reactions!(group)
    group.comment_reactions.find_each do |reaction|
      reactable = existing_clone(reaction.reactable)
      Reaction.create!(reactable: reactable, user: reaction.user, reaction: reaction.reaction)
    end
  end

  # After the group is saved, save cloned discussions and polls.
  # Discussions/polls connect to groups through topics, so the topicable
  # must be persisted before the topic can reference it.
  def save_cloned_content!(clone_group)
    cloned_discussions = clone_group.instance_variable_get(:@_cloned_discussions) || []
    cloned_polls = clone_group.instance_variable_get(:@_cloned_polls) || []

    cloned_discussions.each do |cd|
      cd.topic.group = clone_group
      cd.save!
    end

    cloned_polls.each do |cp|
      cp.topic.group = clone_group
      cp.save!
    end
  end

  def new_clone_group(group, clone_parent = nil)

    required_values = {
      handle: nil,
      is_visible_to_public: false,
      is_visible_to_parent_members: false,
      discussion_privacy_options: 'private_only',
      membership_granted_upon: 'approval',
      listed_in_explore: false
    }
    attachments = [:cover_photo, :logo, :files, :image_files]

    clone_group = new_clone(group, required_values, attachments)
    clone_group.parent = clone_parent
    clone_group.tags = group.tags.map { |tag| new_clone_tag(tag) }

    clone_group.memberships = group.memberships.map {|m| new_clone_membership(m) }
    clone_group.subgroups = group.subgroups.enabled.map { |g| new_clone_group(g, clone_group) }

    # Store cloned discussions and polls for deferred save via save_cloned_content!.
    # These connect to the group through topics, so they must be saved after the group.
    clone_group.instance_variable_set(:@_cloned_discussions,
      group.discussions.kept.map {|d| new_clone_discussion_and_events(d) })
    clone_group.instance_variable_set(:@_cloned_polls,
      group.polls.kept.map {|p| new_clone_poll(p) })

    clone_group
  end

  def new_clone_discussion(discussion)

    attachments = [:files, :image_files]
    new_clone(discussion, {}, attachments)
  end

  def new_clone_topic(topic, topicable)
    clone_topic = new_clone(topic)
    clone_topic.topicable = topicable
    clone_topic
  end

  def new_clone_discussion_and_events(discussion)
    clone_discussion = new_clone_discussion(discussion)
    clone_topic = new_clone_topic(discussion.topic, clone_discussion)
    clone_discussion.topic = clone_topic

    created_topic_item = new_clone_event(discussion.created_topic_item)
    created_topic_item.itemable = clone_discussion

    drop_kinds = %w[poll_closed_by_user poll_expired poll_reopened]
    created_topic_item_id = discussion.created_topic_item&.id
    thread_events = discussion.topic.items.order(:sequence_id)
      .reject { |i| drop_kinds.include?(i.kind) || i.id == created_topic_item_id }
      .map { |topic_item| new_clone_event_and_itemable(topic_item) }

    clone_topic.items = [ created_topic_item ] + thread_events
    clone_discussion
  end

  def new_clone_poll(poll)
    attachments = [:files, :image_files]

    clone_poll = new_clone(poll, {}, attachments)
    # In-thread polls share the discussion's cloned topic;
    # standalone polls get their own topic
    clone_poll.topic = existing_clone(poll.topic) || new_clone_topic(poll.topic, clone_poll)
    clone_poll.poll_options = poll.poll_options.map {|poll_option| new_clone_poll_option(poll_option) }
    clone_poll.stances = poll.stances.map {|stance| new_clone_stance(stance) }
    clone_poll.outcomes = poll.outcomes.map {|outcome| new_clone_outcome(outcome) }
    if !clone_poll.template
      if poll.outcomes.empty?
        clone_poll.closed_at = nil
        clone_poll.closing_at = 3.days.from_now
        clone_poll.opening_at = nil
        clone_poll.opened_at = Time.now
      else
        clone_poll.closed_at = poll.outcomes.first.created_at
      end
    end

    clone_poll
  end

  def new_clone_poll_option(poll_option)
    clone_poll_option = new_clone(poll_option)
    clone_poll_option.poll = existing_clone(poll_option.poll)
    clone_poll_option
  end

  def new_clone_stance(stance)
    attachments = [:files, :image_files]
    clone_stance = new_clone(stance, {}, attachments)
    clone_stance.stance_choices = stance.stance_choices.map {|sc| new_clone_stance_choice(sc) }
    clone_stance.poll = existing_clone(stance.poll)
    clone_stance
  end

  def new_clone_stance_choice(sc)
    clone_sc = new_clone(sc)
    clone_sc.poll_option = existing_clone(sc.poll_option)
    clone_sc
  end

  def new_clone_outcome(outcome)

    attachments = [:files, :image_files]
    clone_outcome = new_clone(outcome, {}, attachments)
  end

  def new_clone_event(topic_item)
    new_clone(topic_item)
  end

  def new_clone_event_and_itemable(topic_item)
    clone_event = new_clone_event(topic_item)

    case topic_item.itemable_type
    when 'Poll'
      clone_event.itemable = new_clone_poll(topic_item.itemable)
    when 'Comment'
      clone_event.itemable = new_clone_comment(topic_item.itemable)
    when 'Stance'
      clone_event.itemable = new_clone_stance(topic_item.itemable)
    when 'Outcome'
      clone_event.itemable = new_clone_outcome(topic_item.itemable)
    when 'Discussion'
      clone_event.itemable = new_clone_discussion(topic_item.itemable)
    when nil
      # nothing
    else
      raise "unrecognised itemable_type #{topic_item.itemable_type}"
    end

    clone_event
  end

  def new_clone_membership(membership)
    clone_membership = new_clone(membership)
    clone_membership.group = existing_clone(membership.group)
    clone_membership
  end

  def new_clone_comment(comment)
    attachments = [:files, :image_files]
    clone_comment = new_clone(comment, {}, attachments)
    clone_comment.parent = existing_clone(comment.parent)
    clone_comment
  end

  def new_clone_tag(tag)
    clone_tag = new_clone(tag)
    clone_tag.group = existing_clone(tag.group)
    clone_tag
  end

  def new_clone(record, required_values = {}, attachments = [])
    @cache["#{record.class}-#{record.id}"] ||= begin
      clone = record.class.new
      copy_fields = record.class.column_names - BLOCKED_COLUMNS.fetch(record.class.base_class)

      clone.attributes = new_clone_attributes(record, copy_fields, required_values)

      attachments.each do |name|
        if clone.send(name).class == ActiveStorage::Attached::Many
          clone.send(name).attach(record.send(name).blobs)
        else
          clone.send(name).attach record.send(name).blob
        end
      end

      clone
    end
  end

  def new_clone_attributes(record, copy_fields = [], required_values = {})
    attrs = {}
    copy_fields.each do |field|
      value = record.read_attribute(field)
      if value.nil?
        attrs[field] = value
      elsif field.ends_with?('_at')
        attrs[field] = value.to_datetime + (DateTime.now - @recorded_at.to_datetime)
      elsif field.ends_with?('_on')
        attrs[field] = value.to_date + (Date.today - @recorded_at.to_date)
      else
        attrs[field] = value
      end
    end

    required_values.each_pair do |key, value|
      attrs[key] = value
    end

    attrs
  end

  def existing_clone(record)
    @cache["#{record.class}-#{record.id}"]
  end
end
