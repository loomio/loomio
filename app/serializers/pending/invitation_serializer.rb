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
end
