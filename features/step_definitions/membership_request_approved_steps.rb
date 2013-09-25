Given(/^my membership request has been approved$/) do
  ManageMembershipRequests.approve!(@membership_request, approved_by: @group.admins.first )
end

Then(/^I should get a membership request approved notificaiton$/) do
  @user.notifications.joins(:event).
      where('events.kind = ?', 'membership_request_approved').
      order('notifications.id').should exist
end
