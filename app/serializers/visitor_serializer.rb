class VisitorSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :community_id, :name, :email, :participation_token, :avatar_kind, :avatar_initials, :gravatar_md5, :updated_at, :created_at

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_gravatar_md5?
    object.avatar_kind == 'gravatar'
  end
end
