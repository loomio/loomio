class Events::MembershipRequestApproved < Event
  after_create :notify_users!

  def self.publish!(membership, approver)
    UserMailer.delay.group_membership_approved(membership.user, membership.group)
    create!(:kind => "membership_request_approved", :user => approver, :eventable => membership)
  end

  def membership
    eventable
  end

  private

  def notify_users!
    notify!(membership.user)
  end

  handle_asynchronously :notify_users!
end
