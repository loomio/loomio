class Pending::InvitationSerializer < Pending::BaseSerializer
  def name
    object.recipient_name
  end

  def email
    object.recipient_email
  end
end
