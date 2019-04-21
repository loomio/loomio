class ReceivedEmailService
  def self.create(received_email: )
    return false unless received_email.valid?
    case route_for_email(received_email|)
    when :discussion
      
      authorize user can create discussion
    when :comment
      authorize user can create comment
    else
      false
    end
  end
  private

  def self.route_for_email(received_email)
    local_part = received_email.receiving_address.split('@').first
    if /(d=\d+)&(u=\d+)&(k=\w+)/.match(local_part)
      :comment
    elsif Group.find_by(handle: local_part)
      :discussion
    end
  end
end
