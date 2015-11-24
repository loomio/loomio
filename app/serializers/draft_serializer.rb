class DraftSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :draftable_type, :draftable_id, :payload
end
