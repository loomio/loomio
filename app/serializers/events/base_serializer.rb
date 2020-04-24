class Events::BaseSerializer < ApplicationSerializer
  attributes :id, :sequence_id, :position, :depth, :child_count, :kind,
    :discussion_id, :created_at, :eventable_id, :eventable_type, :custom_fields,
    :pinned, :pinned_title, :parent_id

  has_one :actor, serializer: AuthorSerializer, root: :users
  has_one :eventable, polymorphic: true
  has_one :discussion, serializer: Simple::DiscussionSerializer, root: :discussions
  has_one :parent, serializer: Events::BaseSerializer, root: :events

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
    ["poll_edited", "discussion_edited"].include? object.kind
  end
end
