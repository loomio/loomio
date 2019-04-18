class ReceivedEmailService
  def self.create(received_email: )
    return false unless received_email.valid?
    case route_for_email(received_email|)
    when :discussion_create
    when :poll_create
      UserMailer.start_decision(received_email: self).deliver_now
    when :comment_create
    when :user_not_found
    when :group_not_found
    else
      false
    end
  end
  private

  def self.route_for_email(received_email)
    case recipient_local_part
    if received_email.receipient_address
      recipient address minus reply_hostname is a group handle?
      :discussion_create
      if discussion is recorgnised in the group
      else
        create discussion
        invite everyone listed in the email.
      end
    elsif recipient_local
    if subect matches these conditions

  end
end
