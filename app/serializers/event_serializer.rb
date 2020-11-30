class EventSerializer < ApplicationSerializer
  attributes :id, :sequence_id, :position, :depth, :child_count, :descendant_count, :kind,
    :discussion_id, :created_at, :eventable_id, :eventable_type, :custom_fields,
    :pinned, :pinned_title, :parent_id, :actor_id, :position_key, :recipient_message

  has_one :actor, serializer: AuthorSerializer, root: :users
  has_one :eventable, polymorphic: true
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :parent, serializer: EventSerializer, root: :parent_events

  # for discussion moved event
  has_one :source_group, serializer: GroupSerializer, root: :groups

  def parent
    cache_fetch(:events_by_id, object.parent_id) { nil }
  end

  def include_eventable?
    !(object.kind == "new_discussion" && exclude_type?('discussion'))
  end

  def eventable
    case object.eventable_type
    when 'Discussion' then cache_fetch(:discussions_by_id, object.eventable_id) { object.eventable }
    when 'Poll' then cache_fetch(:polls_by_id, object.eventable_id) { object.eventable }
    when 'Comment' then cache_fetch(:comments_by_id, object.eventable_id) { object.eventable }
    when 'Stance' then cache_fetch(:stances_by_id, object.eventable_id) { object.eventable }
    when 'Outcome' then cache_fetch(:outcomes_by_id, object.eventable_id) { object.eventable }
    when 'Reaction' then cache_fetch(:reactions_by_id, object.eventable_id) { object.eventable }
    when 'Membership' then cache_fetch(:memberships_by_id, object.eventable_id) { object.eventable }
    when 'Group' then cache_fetch(:groups_by_id, object.eventable_id) { object.eventable }
    when 'MembershipRequest' then cache_fetch(:membership_requests_by_id, object.eventable_id) { object.eventable }
    else
      raise "waht is it? #{object.eventable} #{object.kind}"
      object.eventable
    end
  end

  def position_key
    if object.kind == "new_discussion"
      "00000"
    else
      object.position_key
    end
  end

  def source_group
    Group.find_by(id: object.custom_fields['source_group_id'])
  end

  def include_source_group?
    object.kind == "discussion_moved" && object.custom_fields['source_group_id'].present?
  end

  def pinned_title
    object.custom_fields['pinned_title']
  end

  def include_custom_fields?
    ["poll_edited", "discussion_edited", "discussion_moved"].include? object.kind
  end

end
