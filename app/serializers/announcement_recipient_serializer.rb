class AnnouncementRecipientSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :username, :logo_type, :logo_url

  def logo_type
    object.avatar_kind
  end

  def logo_url
    case object.avatar_kind
    when 'uploaded' then object.avatar_url
    when 'gravatar' then Digest::MD5.hexdigest(object.email.to_s.downcase)
    when 'initials' then object.avatar_initials
    end
  end
end
