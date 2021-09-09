class DemoService
  def self.clone_group(group: , actor: )
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
    ]

    required_values = {
      handle: nil,
      is_visible_to_public: false,
      is_visible_to_parent_members: false,
      discussion_privacy_options: 'private_only',
      membership_granted_upon: 'approval',
      listed_in_explore: false
    }

    clone = new_clone(group, copy_fields, required_values)

    clone.tags = group.tags.map do |t|
      Tag.new({ name: t.name, color: t.color, priority: t.priority })
    end

    clone.creator = actor
    clone.subscription = Subscription.new(plan: 'demo')
    clone.discussions = group.discussions.map {|d| clone_discussion(d) }
    clone.polls = group.polls.map {|p| clone_poll(p) }

    clone.save!
    clone.reload
    clone
  end

  def self.clone_discussion(discussion)
    copy_fields = %w[
      author_id
      group_id
      title
      description
      description_format
      closed_at
      pinned
      max_depth
      newest_first
      content_locale
      link_previews
    ]

    required_values = {
      private: true
    }

    clone = Discussion.new

    copy_fields.each do |field|
      clone[field] = discussion[field]
    end

    required_values.each_pair do |key, value|
      clone[key] = value
    end

      kind: 'created_event',
      user: actor
    )

    item_copy_fields = %w[
      user_id
      kind
      depth
      discussion_id
      sequence_id
      position
      position_key
      child_count
      pinned
      descendant_count
      custom_fields
    ]

    clone.created_event = new_clone(discussion.created_event, item_copy_fields, item_required_values)

    clone.items = discussion.items.map do |item|
      new_clone(item, item_copy_fields, item_required_values)
      item.eventable = new_clone(item.eventable,
    end

    clone.save!
    clone.reload
    clone
  end

  def new_clone(record, copy_fields, required_values)
    clone = record.class.new

    copy_fields.each do |field|
      clone[field] = record[field]
    end

    required_values.each do |key, value|
      clone[key] = value
    end

    clone
  end

end
