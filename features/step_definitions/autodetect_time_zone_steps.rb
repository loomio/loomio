Given(/^I have a user account with no time_zone$/) do
  @user = FactoryGirl.create(:user, time_zone: nil)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@user)
end

Given(/^I follow the invitation link$/) do
  visit invitation_path(@invitation.token)
end

When(/^I sign in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password'
  click_on 'sign-in-btn'
end

Then(/^I should have a time_zone defined$/) do
  @user.reload
  @user.time_zone.should_not be_blank
end

Given(/^I am invited to join a Loomio Group$/) do
  @user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@user)
  @invitation = InvitationService.create_invite_to_join_group(group: @group,
                                                              inviter: @user,
                                                              recipient_email: 'me@email.com')
end

Then(/^the new user should have a time zone$/) do
  User.find_by_email('jim@jam.com').time_zone.should be_present
end
