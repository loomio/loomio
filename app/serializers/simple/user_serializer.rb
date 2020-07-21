class Simple::UserSerializer < ActiveModel::Serializer

  embed :ids, include: true
  attributes :id, :key, :name, :label, :username, :avatar_kind, :avatar_initials, :email_hash, :avatar_url

  def email_hash
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end
  
  def titles
    object.experiences['titles'] || {}
  end

  def include_email_hash?
    object.avatar_kind == 'gravatar'
  end

  def label
    username
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
