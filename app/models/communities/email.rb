class Communities::Email < Communities::Base
  set_community_type :email
  set_custom_fields  :emails

  validates :emails, length: { minimum: 1 }

  def includes?(participant)
    emails.include?(participant.email)
  end

  def participants
    @participants ||= emails.map { |email| Visitor.new(email: email) }
  end
end
