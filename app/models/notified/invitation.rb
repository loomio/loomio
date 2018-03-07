class Notified::Invitation < Notified::Base
  def id
    model
  end

  def title
    model
  end

  def logo_url
    Invitation.new(recipient_email: model).get_avatar_initials
  end

  def logo_type
    :initials
  end
end
