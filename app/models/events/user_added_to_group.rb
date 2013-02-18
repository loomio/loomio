class Events::UserAddedToGroup < Event
  after_create :notify_users!

  def self.publish!(membership)
    create!(:kind => "user_added_to_group", :eventable => membership)
  end

  def membership
    eventable
  end

  private

  def notify_users!
    # Send email only if the user has already accepted invitation to Loomio
    if membership.user.accepted_or_not_invited?
      UserMailer.added_to_group(membership).deliver
    end
    notify!(membership.user)
  end

  handle_asynchronously :notify_users!
end