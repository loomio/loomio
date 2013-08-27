class Events::InvitationAccepted < Event
  after_create :notify_users!

  def self.publish!(membership)
    create!(:kind => "invitation_accepted", :eventable => membership)
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