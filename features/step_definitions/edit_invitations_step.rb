When(/^I view click pending invitations from the group page$/) do
  visit group_path(@group)
  find("#group-member-options").click
  click_on 'Pending invitations'
end

Then(/^I should see the pending invitations for the group$/) do
  page.should have_content 'Pending invitations'
end

When(/^I visit the group page and click Invite People$/) do
  visit group_path(@group)
  click_on 'Invite people'
end

When(/^invite a couple of people to join the group$/) do
  fill_in 'invitees', with: 'rob@enspiral.com, joe@webnet.com'
  fill_in 'invite_people_message_body', with: 'yo join up {invitation_link}'
  click_on 'Send invitations'
end

Then(/^there should be a couple of pending invitations to those people$/) do
  visit group_invitations_path(@group)
  page.should have_content 'rob@enspiral.com'
  page.should have_content 'joe@webnet.com'
end

Then(/^the flash notice should inform me of (\d+) invitations being sent$/) do |arg1|
  page.should have_content "#{arg1} invitation(s) sent"
end

Given(/^there is a pending invitation to join the group$/) do
  CreateInvitation.to_join_group(recipient_email: 'me@you.com', 
                                 group: @group,
                                 inviter: @user)
end

When(/^I cancel the pending invitation$/) do
  visit group_invitations_path(@group)
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
