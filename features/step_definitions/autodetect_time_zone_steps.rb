Given(/^I have a user account with no time_zone$/) do
  @user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@user)
  @user.time_zone.should be_nil
end

When(/^I sign in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
end

Then(/^I should have a time_zone defined$/) do
  @user.reload
  @user.time_zone.should_not be_blank
end

Given(/^I am invited to join a Loomio Group$/) do
  @user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@user)
  @invitation = CreateInvitation.to_join_group(group: @group, 
                                               inviter: @user,
                                               recipient_email: 'me@email.com')
end

When(/^I sign up as a new user$/) do
  visit invitation_path(@invitation)
  within '.signup-form' do
    fill_in :user_name, with: 'Jim Jameson'
    fill_in :user_email, with: 'jim@jam.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_on 'Sign up'
  end
end

Then(/^the new user should have a time zone$/) do
  User.find_by_email('jim@jam.com').time_zone.should be_present
end
