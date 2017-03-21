class CommunitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :custom_fields, :community_type, :identity_id
end
