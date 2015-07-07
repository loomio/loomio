class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :username, :avatar_initials, :avatar_kind, :avatar_url, :profile_url, :gravatar_md5, :time_zone, :selected_locale, :detected_locale, :search_fragment

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_gravatar_md5?
    object.avatar_kind == 'gravatar'
  end

  def avatar_url
    object.avatar_url('medium')
  end

  def profile_url
    object.avatar_url :large
  end

  def search_fragment
    scope[:q]
  end

  def scope
    super || {}
  end

end
