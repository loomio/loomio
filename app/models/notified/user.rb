class Notified::User < Notified::Base
  def id
    model.id
  end

  def title
    "#{model.name} (#{model.username})"
  end

  def logo_type
    model.avatar_kind
  end

  def logo_url
    case logo_type
    when 'uploaded' then model.avatar_url
    when 'gravatar' then Digest::MD5.hexdigest(object.email.to_s.downcase)
    when 'initials' then model.avatar_initials
    end
  end

  def notified_ids
    Array(model.id)
  end
end
