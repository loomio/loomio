Given(/^I am a group admin$/) do
  @group_admin = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin! @group_admin
  login_automatically @group_admin
end

When(/^I invite "(.*?)" to our group$/) do |arg1|
  visit group_path(@group)
  click_on 'invite-new-members'
  fill_in "invitees", with: arg1
  click_on 'Send invitations'
end

Then(/^"(.*?)" should get an invitation to join the group$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should == [arg1]
  last_email.reply_to.should == [@group_admin.email]
end

Given(/^there is a user called "(.*?)" with email "(.*?)"$/) do |arg1, arg2|
  @user = FactoryGirl.create(:user, name: arg1, email: arg2)
end

Then(/^"(.*?)" should be auto\-added to the group$/) do |arg1|
  @group.members.should include User.find_by_email('jim@jam.com')
end

Given(/^there is a group member with email "(.*?)"$/) do |arg1|
  @group_member = FactoryGirl.create(:user, email: arg1)
  @group.add_member! @group_member
end

Then(/^I should be told "(.*?)" is already a member$/) do |arg1|
  page.should have_content("already in group")
end

Given(/^I am invited to join a group$/) do
  @group_admin = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin! @group_admin
  @invite_people = InvitePeople.new(recipients: 'jim@jam.com', message_body: 'please click the invitation link below')
  CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: @group_admin)
end

When(/^I accept my invitation via email$/) do
  invitation_url_regex = /https?:\/\/[\S]+/
  url = last_email_text_body.match(invitation_url_regex)[0]
  path = URI.parse(url).path
  visit path
end

When(/^I sign up as a new user$/) do
  fill_in :user_name, with: 'Jim Jameson'
  fill_in :user_email, with: 'jim@jam.com'
  fill_in :user_password, with: 'password'
  fill_in :user_password_confirmation, with: 'password'
  find('input[name=commit]').click()
  @user = User.find_by_email('jim@jam.com')
end

Then(/^I should see the signup form prepopulated with my email address$/) do
  page.should have_css('#user_email[value="jim@jam.com"]')
end

Given(/^I am invited at "(.*?)" to join a group$/) do |arg1|
  @group = FactoryGirl.create(:group)
  @invite_people = InvitePeople.new(recipients: arg1, message_body: 'please click the invitation link below')
  CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: @group.admins.first)
end

Then(/^I should be a member of the group$/) do
  @group.members.should include @user
end

When(/^I follow an invitation link I have already used$/) do
  @group = FactoryGirl.create(:group)
  @user = FactoryGirl.create(:user)
  @coordinator = FactoryGirl.create(:user)
  @group.add_admin!(@coordinator)
  @invitation = CreateInvitation.to_join_group(group: @group,
                                               inviter: @coordinator,
                                               recipient_email: 'jim@jimmy.com')
  AcceptInvitation.and_grant_access!(@invitation, @user)
  visit invitation_path(@invitation)
end

Then(/^I should be redirected to the group page$/) do
  URI.parse(current_url).path.should == group_path(@group)
end

Then(/^I should be told the invitation link has already been used$/) do
  page.should have_content("This invitation has already been used. Please log in to continue to your group.")
end

When(/^I click an invitation link I have already used$/) do
  @group = FactoryGirl.create(:group)
  @coordinator = FactoryGirl.create(:user)
  @group.add_admin!(@coordinator)
  @invitation = CreateInvitation.to_join_group(group: @group,
                                               inviter: @coordinator,
                                               recipient_email: 'jim@jimmy.com')
  AcceptInvitation.and_grant_access!(@invitation, @user)
  visit invitation_path(@invitation)
end
