Given(/^there is a pending invitation to a group$/) do
  @coordinator = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@coordinator)
  @invitation = CreateInvitation.to_join_group(group: @group, 
                                               inviter: @coordinator,
                                               recipient_email: 'jim@jimmy.com')
end

When(/^the group coordinator cancels the invitation$/) do
  login_automatically @coordinator
  visit group_invitations_path(@group)
  click_on 'Cancel'
end

Then(/^the invitation should be cancelled$/) do
  @invitation.reload
  @invitation.should be_cancelled
end

Given(/^there is a cancelled invitation to a group$/) do
  @coordinator = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@coordinator)
  @invitation = CreateInvitation.to_join_group(group: @group, 
                                               inviter: @coordinator,
                                               recipient_email: 'jim@jimmy.com')
  @invitation.cancel!(canceller: @coordinator)
end

When(/^the user clicks the invitation$/) do
  visit invitation_path(@invitation)
end

Then(/^they should be told the invitaiton was cancelled$/) do
  page.should have_content('cancelled')
end

When(/^I load an unknown invitation link$/) do
  visit invitation_path(id: 'asjdhaskdjhasd')
end

Then(/^I should be told the invitation token was not found$/) do
  page.should have_content 'Could not find invitation'
end
