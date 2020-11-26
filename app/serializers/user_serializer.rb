class UserSerializer < AuthorSerializer
  attributes :short_bio,
             :short_bio_format,
             :content_locale,
             :location,
             :email_verified,
             :has_password,
             :email,
             :attachments

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

  def include_has_password?
    scope[:include_password_status]
  end

  def include_email?
    scope && scope[:include_email]
  end
end
