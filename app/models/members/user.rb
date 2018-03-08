class Members::User < Members::Base
  def priority
    1
  end

  def title
    model.name
  end

  def logo_url
    case logo_type
    when 'uploaded' then model.avatar_url
    when 'gravatar' then Digest::MD5.hexdigest(model.email.to_s.downcase)
    when 'initials' then model.avatar_initials
    end
  end

  def logo_type
    model.avatar_kind
  end

  def last_notified_at
    model.last_notified_at
  end
end
