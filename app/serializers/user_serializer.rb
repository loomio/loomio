class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :username, :short_bio, :avatar_initials, :avatar_kind,
             :avatar_url, :gravatar_md5, :time_zone, :search_fragment, :label,
             :locale, :location, :city, :region, :country, :created_at, :email_verified, :has_password,
             :last_seen_at

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

  def include_has_password?
    scope[:include_password_status]
  end

  def search_fragment
    scope[:q]
  end

  def scope
    super || {}
  end

end
