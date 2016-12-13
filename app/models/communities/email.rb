class Communities::Email < Communities::Base
  attr_accessor :emails

  def includes?(participant)
    emails.include?(participant.email)
  end

  def participants
    @participants ||= email.map { |email| Visitor.new(email: email) }
  end
end
