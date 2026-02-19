class RecordCloner
  def initialize(recorded_at:)
    @recorded_at = recorded_at
    @cache = {}
  end

  def create_clone_group_for_public_demo(group, handle)
    clone_group = new_clone_group(group)
    clone_group.subscription = Subscription.new(plan: 'demo')
    clone_group.handle = handle
    clone_group.is_visible_to_public = true
    clone_group.members_can_create_subgroups = false
    clone_group.members_can_add_members = false
    clone_group.members_can_add_guests = false
    clone_group.members_can_announce = true
    clone_group.discussion_privacy_options = 'public_only'
    clone_group.membership_granted_upon = 'request'

    # Apply overrides to cloned discussions and polls before saving
    cloned_discussions = clone_group.instance_variable_get(:@_cloned_discussions) || []
    cloned_polls = clone_group.instance_variable_get(:@_cloned_polls) || []
    cloned_discussions.each {|d| d.private = false }
    cloned_polls.each {|p| p.specified_voters_only = false }

    clone_group.save!
    save_cloned_content!(clone_group)

    update_tag_colors(clone_group, group)

    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| EventService.repair_discussion(d.id) }
    clone_group.reload
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
    store_source_record_ids(clone_group)


    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| EventService.repair_discussion(d.id) }
    clone_group.add_member! actor
    clone_group.reload
  end

  def clone_trial_content_into_group(group, actor)
    source_group = Group.find_by(handle: 'trial-group-template')

    cloned_discussions = source_group.discussions.kept.map {|d| new_clone_discussion_and_events(d) }
    cloned_polls = source_group.polls.kept.map {|p| new_clone_poll(p) }

    group.instance_variable_set(:@_cloned_discussions, cloned_discussions)
    group.instance_variable_set(:@_cloned_polls, cloned_polls)

    group.save!
    save_cloned_content!(group)

    update_tag_colors(group, source_group)
    store_source_record_ids(group)
    TranslationService.translate_group_content!(group, actor.locale)


    group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end

    group.discussions.each {|d| EventService.repair_discussion(d.id) }
    group.reload

    group.save!

    group
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

    store_source_record_ids(clone_group)

    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| EventService.repair_discussion(d.id) }
    clone_group.reload
    clone_group
  end

  # After the group is saved, save cloned discussions and polls.
  # Discussions/polls connect to groups through topics, so the topicable
  # must be persisted before the topic can reference it.
  def save_cloned_content!(clone_group)
    cloned_discussions = clone_group.instance_variable_get(:@_cloned_discussions) || []
    cloned_polls = clone_group.instance_variable_get(:@_cloned_polls) || []

    cloned_discussions.each do |cd|
      cd.group = clone_group
      cd.save!
      # build_default_topic + save_pending_topic_items callbacks handle
      # persisting the topic and its events
    end

    cloned_polls.each do |cp|
      cp.group = clone_group
      cp.save!
      # assign_topic! callback handles creating the topic
    end
  end

  def new_clone_group(group, clone_parent = nil)
    copy_fields = %w[
      name
      description
      description_format
      members_can_add_members
      members_can_edit_discussions
      members_can_edit_comments
      members_can_raise_motions
      members_can_vote
      members_can_start_discussions
      members_can_create_subgroups
      members_can_announce
      new_threads_max_depth
      new_threads_newest_first
      admins_can_edit_user_content
      members_can_add_guests
      members_can_delete_comments
      link_previews
      created_at
      updated_at
      category
    ]

    required_values = {
      handle: nil,
      is_visible_to_public: false,
      is_visible_to_parent_members: false,
      discussion_privacy_options: 'private_only',
      membership_granted_upon: 'approval',
      listed_in_explore: false
    }
    attachments = [:cover_photo, :logo, :files, :image_files]

    clone_group = new_clone(group, copy_fields, required_values, attachments)
    clone_group.parent = clone_parent

    clone_group.memberships = group.memberships.map {|m| new_clone_membership(m) }
    clone_group.subgroups = group.subgroups.published.map {|g| new_clone_group(g, clone_group) }

    # Store cloned discussions and polls for deferred save via save_cloned_content!.
    # These connect to the group through topics, so they must be saved after the group.
    clone_group.instance_variable_set(:@_cloned_discussions,
      group.discussions.kept.map {|d| new_clone_discussion_and_events(d) })
    clone_group.instance_variable_set(:@_cloned_polls,
      group.polls.kept.map {|p| new_clone_poll(p) })

    clone_group
  end

  def new_clone_discussion(discussion)
    copy_fields = %w[
      author_id
      title
      discussion_template_id
      discussion_template_key
      description
      description_format
      content_locale
      link_previews
      created_at
      updated_at
      discarded_at
      template
      tags
    ]

    required_values = {
      private: true
    }

    attachments = [:files, :image_files]
    new_clone(discussion, copy_fields, required_values, attachments)
  end

  def new_clone_discussion_and_events(discussion)
    clone_discussion = new_clone_discussion(discussion)

    # Build topic for the cloned discussion
    clone_topic = Topic.new(
      topicable: clone_discussion,
      max_depth: discussion.max_depth,
      newest_first: discussion.newest_first,
      last_activity_at: discussion.last_activity_at
    )
    clone_discussion.topic = clone_topic

    created_event = new_clone_event(discussion.created_event)
    created_event.eventable = clone_discussion

    drop_kinds = %w[poll_closed_by_user poll_expired poll_reopened]
    created_event_id = discussion.created_event&.id
    thread_events = discussion.items.order(:sequence_id)
      .reject { |i| drop_kinds.include?(i.kind) || i.id == created_event_id }
      .map { |event| new_clone_event_and_eventable(event) }

    # All events go into the topic's items (comments are saved via events' belongs_to autosave)
    clone_topic.items = [created_event] + thread_events

    # Store cloned polls for deferred save (polls need topic_id set after topic is created)
    clone_discussion.instance_variable_set(:@_cloned_polls,
      discussion.polls.map {|p| new_clone_poll(p) })
    clone_discussion
  end

  def new_clone_poll(poll)
    copy_fields = %w[
      author_id
      closing_at
      closed_at
      created_at
      updated_at
      discarded_at
      title
      details
      poll_type
      process_name
      process_subtitle
      voter_can_add_options
      anonymous
      details_format
      hide_results
      discarded_by
      specified_voters_only
      notify_on_closing_soon
      notify_on_open
      content_locale
      link_previews
      shuffle_options
      limit_reason_length
      meeting_duration
      time_zone
      dots_per_person
      minimum_stance_choices
      maximum_stance_choices
      can_respond_maybe
      min_score
      max_score
      template
      agree_target
      chart_type
      default_duration_in_days
      stance_reason_required
      poll_option_name_format
      reason_prompt
      tags
      poll_template_id
      poll_template_key
    ]
    attachments = [:files, :image_files]

    clone_poll = new_clone(poll, copy_fields, {}, attachments)
    clone_poll.poll_options = poll.poll_options.map {|poll_option| new_clone_poll_option(poll_option) }
    clone_poll.stances = poll.stances.map {|stance| new_clone_stance(stance) }
    clone_poll.outcomes = poll.outcomes.map {|outcome| new_clone_outcome(outcome) }
    if !clone_poll.template
      if poll.outcomes.empty?
        clone_poll.closed_at = nil
        clone_poll.closing_at = 3.days.from_now
      else
        clone_poll.closed_at = poll.outcomes.first.created_at
      end
    end

    clone_poll
  end

  def new_clone_poll_option(poll_option)
    copy_fields = %w[
      name
      icon
      meaning
      prompt
      priority
      score_counts
      total_score
      voter_scores
      voter_count
    ]
    clone_poll_option = new_clone(poll_option, copy_fields)
    clone_poll_option.poll = existing_clone(poll_option.poll)
    clone_poll_option
  end

  def new_clone_stance(stance)
    copy_fields = %w[
      accepted_at
      cast_at
      content_locale
      inviter_id
      latest
      link_previews
      participant_id
      reason
      reason_format
      revoked_at
      created_at
      updated_at
    ]
    attachments = [:files, :image_files]
    clone_stance = new_clone(stance, copy_fields, {}, attachments)
    clone_stance.stance_choices = stance.stance_choices.map {|sc| new_clone_stance_choice(sc) }
    clone_stance.poll = existing_clone(stance.poll)
    clone_stance
  end

  def new_clone_stance_choice(sc)
    copy_fields = %w[ score ]
    clone_sc = new_clone(sc, copy_fields)
    clone_sc.poll_option = existing_clone(sc.poll_option)
    clone_sc
  end

  def new_clone_outcome(outcome)
    copy_fields = %w[
      statement
      latest
      statement_format
      author_id
      review_on
      content_locale
      link_previews
      created_at
      updated_at
    ]

    attachments = [:files, :image_files]
    clone_outcome = new_clone(outcome, copy_fields, {}, attachments)
  end

  def new_clone_event(event)
    copy_fields = %w[
      user_id
      kind
      depth
      sequence_id
      position
      position_key
      child_count
      pinned
      descendant_count
      custom_fields
      created_at
    ]
    new_clone(event, copy_fields)
  end

  def new_clone_event_and_eventable(event)
    clone_event = new_clone_event(event)

    case event.eventable_type
    when 'Poll'
      clone_event.eventable = new_clone_poll(event.eventable)
    when 'Comment'
      clone_event.eventable = new_clone_comment(event.eventable)
    when 'Stance'
      clone_event.eventable = new_clone_stance(event.eventable)
    when 'Outcome'
      clone_event.eventable = new_clone_outcome(event.eventable)
    when 'Discussion'
      clone_event.eventable = new_clone_discussion(event.eventable)
    when nil
      # nothing
    else
      raise "unrecognised eventable_type #{event.eventable_type}"
    end

    clone_event
  end

  def new_clone_membership(membership)
    copy_fields = %w[
      user_id
      inviter_id
      revoked_at
      revoker_id
      admin
      volume
      experiences
      accepted_at
      title
    ]
    clone_membership = new_clone(membership, copy_fields)
    clone_membership.group = existing_clone(membership.group)
    clone_membership
  end

  def new_clone_comment(comment)
    copy_fields = %w[
      user_id
      body
      body_format
      discarded_at
      discarded_by
      content_locale
      link_previews
      created_at
    ]
    attachments = [:files, :image_files]
    clone_comment = new_clone(comment, copy_fields, {}, attachments)
    clone_comment.parent = existing_clone(comment.parent)
    clone_comment
  end

  def new_clone_tag(tag)
    clone_tag = new_clone(tag, %w[name color priority])
    clone_tag.group = existing_clone(tag.group)
    clone_tag
  end

  def new_clone(record, copy_fields = [], required_values = {}, attachments = [])
    @cache["#{record.class}-#{record.id}"] ||= begin
      clone = record.class.new
      record_type = record.class.to_s.underscore.to_sym

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
      value = record.send(field)
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
