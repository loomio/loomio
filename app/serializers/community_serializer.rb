class CommunitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :custom_fields, :community_type, :identity_id, :poll_id, :user_id

  def poll_id
    Hash(scope)[:poll_id]
  end
end
