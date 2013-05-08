Given(/^there is a group$/) do
  @group = FactoryGirl.create(:group)
end

Given(/^I am an admin of that group$/) do
  @group_admin = FactoryGirl.create(:user)
  @group.add_admin! @group_admin
  login_automatically @group_admin
end

Given(/^I am on the group show page$/) do
  visit group_path(@group)
end

When(/^I click Invite people from the members box$/) do
  click_on 'group-member-options'
  within 'ul.group-member-options' do
    click_on 'Invite people'
  end
end

When(/^enter "(.*?)" into the recipients$/) do |arg1|
  fill_in "invitees", with: arg1
end

When(/^fill in the message body$/) do
  fill_in 'invite_people[message_body]', with: 'hi please click the {invitation_link}'
end

When(/^click Send Invitations$/) do
  click_on 'Send invitations'
end

When(/^I invite "(.*?)" to join the group$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^"(.*?)" should get an invitation to join the group$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should == [arg1]
end

Given(/^an invitation to join the group has been sent to "(.*?)"$/) do |arg1|
  @user = FactoryGirl.create(:user)
  @invite_people = InvitePeople.new(recipients: arg1, message_body: 'please click {invitation_link}')
  CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: @user)
end

When(/^I open the email and click the accept invitation link$/) do
  last_email = ActionMailer::Base.deliveries.last
  url = last_email.body.match(/https?:\/\/[\S]+/)[0]
  path = URI.parse(url).path
  puts path
  visit path
end

When(/^sign up as a new user$/) do
  within '.signup-form' do
    fill_in :user_name, with: 'Jim Jameson'
    fill_in :user_email, with: 'jim@jam.com'
    fill_in :user_password, with: 'password'
    fill_in :user_password_confirmation, with: 'password'
    click_on 'Sign up'
  end
end

Then(/^I should be a member of the group$/) do
  @group.members.should include User.find_by_email('jim@jam.com')
end

Then(/^I should be redirected to the group page$/) do
  URI.parse(current_url).path.should == group_path(@group)
end

Given(/^an existing user with email "(.*?)"$/) do |arg1|
  @user = FactoryGirl.create :user, email: arg1
end

When(/^sign in as "(.*?)"$/) do |arg1|
  within '.signin-form' do
    fill_in :user_email, with: arg1
    fill_in :user_password, with: 'password'
    click_on 'Sign in'
  end 
end

Given(/^I am signed in as "(.*?)"$/) do |arg1|
  @user = FactoryGirl.create :user, email: arg1
  login_automatically @user
end
