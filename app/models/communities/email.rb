class Communities::Email < Communities::Base
  include Communities::Notify::Visitors
  set_community_type :email

  def add_members!(emails)
    visitors.where(revoked: true, email: emails).update_all(revoked: false)
    (emails - visitors.pluck(:email)).map { |email| visitors.build(email: email) }
    save if persisted?
  end

  def includes?(participant)
    visitors.where(revoked: false).pluck(:participation_token).include?(participant.participation_token)
  end
end
