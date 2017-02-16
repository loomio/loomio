class Communities::Email < Communities::Base
  set_community_type :email
  set_custom_fields  :emails

  validates :emails, length: { minimum: 1 }

  def includes?(member)
    emails.include?(member.email)
  end

  def members
    @members ||= emails.map { |email| Visitor.new(email: email) }
  end

  def notify!(event)
    # send an email about the event if appropriate
  end
end
