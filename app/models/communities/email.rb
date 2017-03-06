class Communities::Email < Communities::Base
  include Communities::EmailVisitors
  set_community_type :email

  def add_members!(emails)
    visitors.where(revoked: true, email: emails).update_all(revoked: false)
    (emails - visitors.pluck(:email)).map { |email| visitors.build(email: email) }
    save if persisted?
  end

  def includes?(member)
    members.pluck(:participation_token).include?(member.participation_token)
  end

  def members
    @members ||= visitors.where(revoked: false)
  end
end
