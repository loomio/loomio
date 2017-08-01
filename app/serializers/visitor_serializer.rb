class VisitorSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :community_id, :poll_id, :name, :email, :invitation_token, :avatar_kind, :avatar_initials, :gravatar_md5, :updated_at, :created_at

  def poll_id
    object.poll_communities.first&.poll_id
  end

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_gravatar_md5?
    object.avatar_kind == 'gravatar'
  end
end
