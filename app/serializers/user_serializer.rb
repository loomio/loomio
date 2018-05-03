class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :username, :short_bio, :avatar_initials, :avatar_kind,
             :avatar_url, :email_hash, :time_zone, :search_fragment, :label,
             :locale, :location, :created_at, :email_verified, :has_password,
             :last_seen_at, :email

  def name
    object.name || placeholder_name
  end

  def label
    username
  end

  def email_hash
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def include_email_hash?
    object.avatar_kind == 'gravatar'
  end

  def avatar_kind
    if !object.email_verified && !object.name
      'mdi-email-outline'
    else
      object.avatar_kind
    end
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

  def include_email?
    scope[:email_user_ids].to_a.include? object.id
  end

  private

  def placeholder_name
    I18n.t("user.placeholder_name", hostname: object.email.split('@').last, locale: object.locale)
  end

  def scope
    super || {}
  end

end
