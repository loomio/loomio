When(/^I click the pending link$/) do
  click_on 'pending-count'
end

Then(/^I should see the pending invitations for the group$/) do
  page.should have_css(".pending-invitations")
end


Then(/^I should see the no invitations page$/) do
  page.should have_content I18n.t(:"invitation.no_invitations_left")
end

Given(/^the group has run out of invites$/) do
  @group.max_size = 2
  @group.save!
end

When(/^I click 'Invite People'$/) do
  click_on 'Invite people'
end

When(/^invite a couple of people to join the group$/) do
  fill_in 'invitees', with: 'rob@enspiral.com, joe@webnet.com'
  fill_in 'invite_people_form_message_body', with: 'yo join up {invitation_link}'
  click_on 'Invite people'
end

Then(/^there should be a couple of pending invitations to those people$/) do
  visit group_memberships_path(@group)
  page.should have_content 'rob@enspiral.com'
  page.should have_content 'joe@webnet.com'
end

Then(/^the flash notice should inform me of (\d+) invitations being sent$/) do |arg1|
  page.should have_content "#{arg1} invitations sent"
end

Given(/^there is a pending invitation to join the group$/) do
  @group.pending_invitations.first.destroy
  @invitation = InvitationService.create_invite_to_join_group(group: @group,
                                                              inviter: @user,
                                                              recipient_email: 'jim@jimmy.com')
end

When(/^I cancel the pending invitation$/) do
  visit group_memberships_path(@group)
  within 'table.pending-invitations' do
    click_link 'Cancel'
  end
end

Then(/^there should be no more pending invitations$/) do
  @group.pending_invitations.count.should == 0
end

Then(/^the flash notice should confirm the cancellation$/) do
  page.should have_content 'cancelled'
end


Given(/^there is a cancelled invitation to a group$/) do
  @coordinator = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@coordinator)
  @invitation = InvitationService.create_invite_to_join_group(group: @group,
                                                              inviter: @coordinator,
                                                              recipient_email: 'jim@jimmy.com')
  @invitation.cancel!(canceller: @coordinator)
end

When(/^I click the invitation$/) do
  visit invitation_path(@invitation)
end

Then(/^I should be told the invitation was cancelled$/) do
  page.should have_content('cancelled')
end

When(/^I load an unknown invitation link$/) do
  visit invitation_path(id: 'asjdhaskdjhasd')
end

Then(/^I should be told the invitation token was not found$/) do
  page.should have_content 'Could not find invitation'
end
