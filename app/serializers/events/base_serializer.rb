class Events::BaseSerializer < ApplicationSerializer
  attributes :id, :sequence_id, :position, :depth, :child_count, :descendant_count, :kind,
    :discussion_id, :created_at, :eventable_id, :eventable_type, :custom_fields,
    :pinned, :pinned_title, :parent_id, :actor_id, :position_key, :recipient_message

  has_one :actor, serializer: AuthorSerializer, root: :users
  has_one :eventable, polymorphic: true
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :parent, serializer: Events::BaseSerializer, root: :parent_events

  # for discussion moved event
  has_one :source_group, serializer: GroupSerializer, root: :groups


  def eventable
    case object.eventable_type
    when 'Discussion' then scope_fetch(:discussions_by_id, object.eventable_id)
    when 'Poll' then scope_fetch(:polls_by_id, object.eventable_id)
    when 'Comment' then scope_fetch(:comments_by_id, object.eventable_id)
    when 'Stance' then scope_fetch(:stances_by_id, object.eventable_id) { object.eventable }
    else
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

  def actor_id
    object.user_id
  end

  def actor
    object.user || object.eventable&.user
  end

  def pinned_title
    object.custom_fields['pinned_title']
  end

  def include_custom_fields?
    ["poll_edited", "discussion_edited", "discussion_moved"].include? object.kind
  end

end
