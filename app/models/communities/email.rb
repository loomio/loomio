class Communities::Email < Communities::Base
  set_community_type :email
  set_custom_fields  :visitor_ids

  validates :visitor_ids, length: { minimum: 1 }

  def includes?(member)
    emails.include?(member.email)
  end

  def members
    @members ||= Visitor.where(id: visitor_ids, revoked: false)
  end

  def notify!(event)
    # send an email about the event if appropriate
  end
end
