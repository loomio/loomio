class Events::CreatedSerializer < ApplicationSerializer
  attributes :id, :sequence_id, :position, :depth, :child_count, :kind,
    :discussion_id, :created_at, :eventable_id, :eventable_type, :custom_fields,
    :pinned, :pinned_title, :actor_id

  def actor_id
    object.user_id
  end
end
