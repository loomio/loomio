class Members::Invitation < Members::Base
  def priority
    0
  end

  def key
    "invitation-#{model.id}"
  end

  def title
    model.recipient_name || model.recipient_email
  end

  def logo_url
    model.get_avatar_initials
  end

  def logo_type
    :initials
  end

  def last_notified_at
    model.last_notified_at
  end
end
