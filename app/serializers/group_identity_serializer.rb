class GroupIdentitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :custom_fields, :group_id

  has_one :group, serializer: Full::GroupSerializer
  has_one :identity, serializer: IdentitySerializer
end
