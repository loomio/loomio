class CommunitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :custom_fields, :community_type, :poll_id, :user_id, :identifier

  has_one :identity, serializer: IdentitySerializer, root: :identities

  def poll_id
    Hash(scope)[:poll_id]
  end

  def include_poll_id?
    Hash(scope)[:poll_id].present?
  end
end
