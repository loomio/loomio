class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :created_at,
             :updated_at

  has_one :parent, serializer: GroupSerializer, root: 'groups'
end
