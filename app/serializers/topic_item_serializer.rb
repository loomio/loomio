class TopicItemSerializer < ApplicationSerializer
  attributes :id, :sequence_id, :position, :depth, :child_count, :kind,
    :topic_id, :created_at, :itemable_id, :itemable_type, :custom_fields,
    :pinned, :pinned_title, :parent_id, :actor_id, :position_key

  has_one :actor, serializer: AuthorSerializer, root: :users
  has_one :topic, serializer: TopicSerializer, root: :topics
  has_one :itemable, polymorphic: true
  has_one :parent, serializer: TopicItemSerializer, root: :parent_topic_items

  def parent
    cache_fetch(:topic_items_by_id, object.parent_id) { object.parent }
  end

  def include_itemable?
    !(object.kind == "new_discussion" && exclude_type?('discussion'))
  end

  def itemable
    case object.itemable_type
    when 'Discussion' then cache_fetch(:discussions_by_id, object.itemable_id) { object.itemable }
    when 'Poll' then cache_fetch(:polls_by_id, object.itemable_id) { object.itemable }
    when 'Comment' then cache_fetch(:comments_by_id, object.itemable_id) { object.itemable }
    when 'Stance' then cache_fetch(:stances_by_id, object.itemable_id) { object.itemable }
    when 'Outcome' then cache_fetch(:outcomes_by_id, object.itemable_id) { object.itemable }
    else
      object.itemable
    end
  end

  def pinned_title
    object.custom_fields['pinned_title']
  end

  def custom_fields
    return object.custom_fields unless object.kind == "discussion_moved"

    object.custom_fields.except('source_group_id')
  end

  def include_custom_fields?
    object.kind == "discussion_moved"
  end
end
