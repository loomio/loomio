class Pending::InvitationSerializer < Pending::BaseSerializer
  attribute :token

  def avatar_kind
    :initials
  end

  def identity_type
    :invitation
  end

  def has_token
    true
  end

  def token
    object.token
  end

  def email_status
    nil
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


  def has_name?
    name.present?
  end
  alias :include_avatar_initials? :has_name?
end
