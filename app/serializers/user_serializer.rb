class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :key, :name, :username, :avatar_initials, :avatar_kind, :avatar_url, :profile_url, :gravatar_md5, :time_zone, :search_fragment, :label, :locale, :created_at

  def label
    username
  end

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_gravatar_md5?
    object.avatar_kind == 'gravatar'
  end

  def avatar_url
    object.avatar_url :large
  end

  def profile_url
    object.avatar_url :large
  end

  def include_avatar_url?
    object.avatar_kind == 'uploaded'
  end
  alias :include_profile_url? :include_avatar_url?

  def search_fragment
    scope[:q]
  end

  def scope
    super || {}
  end

end
