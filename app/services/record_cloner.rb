class RecordCloner
  def initialize(recorded_at:)
    @recorded_at = recorded_at
    @cache = {}
  end

  def create_clone_group_for_actor(group, actor)
    clone_group = new_clone_group(group)
    clone_group.creator = actor
    clone_group.subscription = Subscription.new(plan: 'demo', owner: actor)
    clone_group.save!
    clone_group.polls.each do |poll|
      poll.update_counts!
      poll.stances.each {|s| s.update_option_scores!}
    end
    clone_group.discussions.each {|d| EventService.repair_thread(d.id) }
    clone_group.add_member! actor
    clone_group.reload
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
    clone_group.discussions = group.discussions.map {|d| new_clone_discussion_and_events(d) }
    clone_group.subgroups = group.subgroups.map {|g| new_clone_group(g, clone_group) }
    clone_group.polls = group.polls.map {|p| new_clone_poll(p) }
    clone_group.tags = group.tags.map { |t| new_clone_tag(t) }

    clone_group
  end

  def new_clone_discussion(discussion)
    copy_fields = %w[
      author_id
      title
      description
      description_format
      pinned_at
      max_depth
      newest_first
      content_locale
      link_previews
      created_at
      updated_at
      closed_at
      last_activity_at
      discarded_at
    ]

    required_values = {
      private: true
    }

    attachments = [:files, :image_files]
    new_clone(discussion, copy_fields, required_values, attachments)
  end

  def new_clone_discussion_and_events(discussion)
    clone_discussion = new_clone_discussion(discussion)
    created_event = new_clone_event(discussion.created_event)
    created_event.eventable = clone_discussion
    clone_discussion.events << created_event
    drop_kinds = %w[poll_closed_by_user poll_expired poll_reopened]
    clone_discussion.items = discussion.items.order(:sequence_id).select{|i| !drop_kinds.include?(i.kind) }.map { |event| new_clone_event_and_eventable(event) }
    clone_discussion.polls = discussion.polls.map {|p| new_clone_poll(p) }
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
      multiple_choice
      voter_can_add_options
      anonymous
      details_format
      anyone_can_participate
      hide_results
      stances_in_discussion
      discarded_by
      specified_voters_only
      notify_on_closing_soon
      content_locale
      link_previews
      shuffle_options
      allow_long_reason
      meeting_duration
      time_zone
      dots_per_person
      pending_emails
      minimum_stance_choices
      can_respond_maybe
      deanonymize_after_close
      max_score
    ]
    attachments = [:files, :image_files]

    clone_poll = new_clone(poll, copy_fields, {}, attachments)
    clone_poll.poll_options = poll.poll_options.map {|poll_option| new_clone_poll_option(poll_option) }
    clone_poll.stances = poll.stances.map {|stance| new_clone_stance(stance) }
    clone_poll.outcomes = poll.outcomes.map {|outcome| new_clone_outcome(outcome) }
    if poll.outcomes.empty?
      clone_poll.closed_at = nil if clone_poll.closed_at && clone_poll.closed_at > DateTime.now
      clone_poll.closing_at = nil if clone_poll.closing_at && clone_poll.closing_at < DateTime.now
    end

    clone_poll
  end

  def new_clone_poll_option(poll_option)
    copy_fields = %w[
      name
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
      admin
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
      volume
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
      archived_at
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
    clone_comment.discussion = existing_clone(comment.discussion)
    clone_comment
  end

  def new_clone_tag(tag)
    new_clone(tag, %w[name color priority])
  end

  def new_clone(record, copy_fields = [], required_values = {}, attachments = [])
    @cache["#{record.class}#{record.id}"] ||= begin
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
    @cache["#{record.class}#{record.id}"]
  end
end
