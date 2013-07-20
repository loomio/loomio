class Events::MembershipRequested < Event
  after_create :notify_users!

  def self.publish!(membership_request)
    create!(:kind => "membership_requested", :eventable => membership_request)
  end

  def membership_request
    eventable
  end

  private

  def notify_users!

    GroupMailer.new_membership_request(eventable)

    membership_request.group_admins.each do |admin|
      notify!(admin)
    end
  end

  handle_asynchronously :notify_users!
end
