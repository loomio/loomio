class Events::SimpleSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :position, :depth, :child_count, :kind, :discussion_id, :created_at, :eventable_id, :eventable_type
end
