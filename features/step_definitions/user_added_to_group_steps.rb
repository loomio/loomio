Given(/^a coordinator adds me to a group I don't already belong to$/) do
  group = FactoryGirl.create :group
  inviter = group.admins.first
  membership = group.add_member! @user, inviter
  Events::UserAddedToGroup.publish!(membership, @user)
end

Then(/^I should get an added to group notificaiton$/) do
  @user.notifications.joins(:event).
      where('events.kind = ?', 'user_added_to_group').
      order('notifications.id').should exist
end
