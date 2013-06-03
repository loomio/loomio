Given(/^there is a group$/) do
  @group = FactoryGirl.create(:group)
end

Given(/^I am an admin of that group$/) do
  @group_admin = FactoryGirl.create(:user)
  @group.add_admin! @group_admin
  login @group_admin
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
  fill_in 'invite_people_message_body', with: 'hi please click the {invitation_link}'
end

When(/^click Send Invitations$/) do
  click_on 'Send invitations'
end

Then(/^"(.*?)" should get an invitation to join the group$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should == [arg1]
  last_email.from.should == [@group_admin.email]
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
  visit path
end

When(/^I sign up as a new user$/) do
  page.should have_content "#{@user.name} invited you to join #{@group.name}"
  fill_in :user_name, with: 'Jim Jameson'
  fill_in :user_email, with: 'jim@jam.com'
  fill_in :user_password, with: 'password'
  fill_in :user_password_confirmation, with: 'password'
  find('input[name=commit]').click()
end

When(/^I click the link to the sign in form$/) do
  click_on 'click here to sign in'
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

When(/^I sign in as "(.*?)"$/) do |arg1|
  fill_in :user_email, with: arg1
  fill_in :user_password, with: 'password'
  find('#sign-in-btn').click()
end

Given(/^I am signed in as "(.*?)"$/) do |arg1|
  @user = FactoryGirl.create :user, email: arg1
  login_automatically @user
end

Given(/^I am a user but i am not signed in$/) do
  @user = FactoryGirl.create :user
end

Given(/^I follow an invitation link I have already used$/) do
  @coordinator = FactoryGirl.create(:user)
  @group.add_admin!(@coordinator)
  @invitation = CreateInvitation.to_join_group(group: @group, 
                                               inviter: @coordinator,
                                               recipient_email: 'jim@jimmy.com')

  AcceptInvitation.and_grant_access!(@invitation, @user)
  visit invitation_path(@invitation)
end

Then(/^I should be told the invitation link has already been used$/) do
  page.should have_content 'invitation has already been used'
end
