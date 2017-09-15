class GroupIdentitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :identity_id, :custom_fields

  has_one :group, serializer: Full::GroupSerializer
end
