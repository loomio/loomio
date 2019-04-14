class AnnouncementRecipientSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :avatar_kind, :avatar_initials, :avatar_url, :email_hash, :emails

  def email_hash
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

  def name
    object.name || object.email
  end

  def include_email?
    !object.name.present?
  end

  def include_emails?
    object.email == "multiple"
  end

  def include_avatar_initials?
    object.avatar_kind == 'initials'
  end

  def include_avatar_url?
    object.avatar_kind == 'uploaded'
  end

  def avatar_url
    {
      small:    object.avatar_url(:small),
      medium:   object.avatar_url(:medium),
      large:    object.avatar_url(:large),
      original: object.avatar_url(:original)
    }
  end
end
