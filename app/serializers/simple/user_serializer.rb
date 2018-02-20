class Simple::UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :name, :username, :avatar_kind, :avatar_initials, :gravatar_md5, :avatar_url

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_gravatar_md5?
    object.avatar_kind == 'gravatar'
  end

  def avatar_url
    {
      small:    object.avatar_url(:small),
      medium:   object.avatar_url(:medium),
      large:    object.avatar_url(:large),
      original: object.avatar_url(:original)
    }
  end

  def include_avatar_url?
    object.avatar_kind == 'uploaded'
  end
end
