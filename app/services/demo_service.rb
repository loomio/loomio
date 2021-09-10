class DemoService
  @cache = {}

  def self.create_clone_group_for_actor(group, actor)
    clone_group = new_clone_group(group)
    clone_group.creator = actor
    clone_group.subscription = Subscription.new(plan: 'demo', owner: actor)
    clone_group.save!
    clone_group.reload
  end

  def self.new_clone_group(group)
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

    clone_group = new_clone(group, copy_fields, required_values)

    clone_group.tags = group.tags.map { |t| new_clone_tag(t) }


    clone_group.discussions = group.discussions.map {|d| new_clone_discussion(d) }
    clone_group.polls = group.polls.map {|p| new_clone_poll(p) }

    clone_group
  end

  def self.new_clone_discussion(discussion)
    copy_fields = %w[
      author_id
      title
      description
      description_format
      closed_at
      pinned
      max_depth
      newest_first
      content_locale
      link_previews
      created_at
      updated_at
    ]
    required_values = {
      private: true
    }

    clone_discussion = new_clone(discussion, copy_fields, required_values)

    created_event = new_clone_event(discussion.created_event)
    created_event.eventable = clone_discussion
    clone_discussion.events << created_event
    clone_discussion.items = discussion.items.map { |event| new_clone_event_and_eventable(event) }
    clone_discussion.polls = discussion.polls.map {|p| new_clone_poll(p) }

    clone_discussion
  end

  def self.new_clone_poll(poll)
    copy_fields = %w[
      author_id
      title
      details
      closing_at
      closed_at
      poll_type
      multiple_choice
      voter_can_add_options
      anonymous
      details_format
      anyone_can_participate
      hide_results_until_closed
      stances_in_discussion
      discarded_at
      discarded_by
      specified_voters_only
      notify_on_closing_soon
      content_locale
      link_previews
      shuffle_options
      allow_long_reason
      created_at
      updated_at
    ]

    required_values = {}

    clone_poll = new_clone(poll, copy_fields, required_values)
    clone_poll.poll_options = poll.poll_options.map {|poll_option| new_clone_poll_option(poll_option) }
    clone_poll.stances = poll.stances.map {|stance| new_clone_stance(stance) }
    clone_poll.outcomes = poll.outcomes.map {|outcome| new_clone_outcome(outcome) }
    clone_poll
  end

  def self.new_clone_poll_option(poll_option)
    copy_fields = %w[
      name
      priority
      score_counts
      voter_scores
      total_score
    ]
    clone_poll_option = new_clone(poll_option, copy_fields)
  end

  def self.new_clone_stance(stance)
    copy_fields = %w[
      participant_id
      reason
      reason_format
      latest
      cast_at
      revoked_at
      admin
      inviter_id
      volume
      accepted_at
      content_locale
      link_previews
      created_at
      updated_at
    ]
    clone_stance = new_clone(stance, copy_fields)
  end

  def self.new_clone_outcome(outcome)
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
    clone_outcome = new_clone(outcome, copy_fields)
  end

  def self.new_clone_event(event)
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
    ]
    new_clone(event, copy_fields)
  end

  def self.new_clone_event_and_eventable(event)
    clone_event = new_clone_event(event)

    case event.eventable_type
    when 'Poll'
      clone_event.eventable = new_clone_poll(event.eventable)
    when 'Comment'
      clone_event.eventable = new_clone_comment(event.eventable)
    when nil
      # nothing
    else
      raise "unrecognised eventable_type #{event.eventable_type}"
    end

    clone_event
  end


  def self.new_clone_tag(tag)
    new_clone(tag, %w[name color priority])
  end

  def self.new_clone(record, copy_fields = [], required_values = {})
    @cache["#{record.class}#{record.id}"] ||= begin
      clone = record.class.new
      record_type = record.class.to_s.underscore.to_sym

      clone.attributes = new_clone_attributes(record, copy_fields, required_values)

      clone
    end
  end

  def self.new_clone_attributes(record, copy_fields = [], required_values = {})
    attrs = {}
    copy_fields.each do |field|
      attrs[field] = record[field]
    end

    required_values.each_pair do |key, value|
      attrs[key] = value
    end

    attrs
  end
end
