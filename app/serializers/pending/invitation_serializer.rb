class Pending::InvitationSerializer < Pending::BaseSerializer
  def avatar_kind
    'initials'
  end

  def avatar_initials
    name.upcase.split(' ').map(&:first).join
  end

  def name
    object.recipient_name
  end

  def email
    object.recipient_email
  end

  private

  def has_email?
    email.present?
  end
  alias :include_email_status? :has_email?

  def has_name?
    name.present?
  end
  alias :include_avatar_initials? :has_name?
end
