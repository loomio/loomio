class GroupIdentitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :custom_fields

  has_one :group, serializer: Full::GroupSerializer
  has_one :identity, serializer: IdentitySerializer
end
