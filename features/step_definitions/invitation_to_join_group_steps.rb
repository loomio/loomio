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
  click_on 'Invite people'
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

Given(/^I am invited to join a group$/) do
  @group_admin = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin! @group_admin
  @invite_people_form = InvitePeopleForm.new(recipients: ['jim@jam.com'], message_body: 'please click the invitation link below')
  InvitationService.invite_to_group(recipient_emails: @invite_people_form.recipients, message: @invite_people_form.message_body, group: @group, inviter: @group_admin)
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
  @invite_people_form = InvitePeopleForm.new(recipients: [arg1], message_body: 'please click the invitation link below')
  InvitationService.invite_to_group(recipient_emails: @invite_people_form.recipients, message: @invite_people_form.message_body, group: @group, inviter: @group.admins.first)
end

Then(/^I should be a member of the group$/) do
  @group.members.should include @user
end

When(/^I follow an invitation link I have already used$/) do
  @group = FactoryGirl.create(:group)
  @user = FactoryGirl.create(:user)
  @coordinator = FactoryGirl.create(:user)
  @group.add_admin!(@coordinator)
  @invitation = InvitationService.create_invite_to_join_group(group: @group,
                                                              inviter: @coordinator,
                                                              recipient_email: 'jim@jimmy.com')
  AcceptInvitation.and_grant_access!(@invitation, @user)
  visit invitation_path(@invitation)
end

Then(/^I should be redirected to the group page$/) do
  URI.parse(current_url).path.should include group_path(@group)
end

Then(/^I should be told the invitation link has already been used$/) do
  page.should have_content("This invitation has already been used. Please log in to continue to your group.")
end

When(/^I click an invitation link I have already used$/) do
  @group = FactoryGirl.create(:group)
  @coordinator = FactoryGirl.create(:user)
  @group.add_admin!(@coordinator)
  @invitation = InvitationService.create_invite_to_join_group(group: @group,
                                                              inviter: @coordinator,
                                                              recipient_email: 'jim@jimmy.com')
  AcceptInvitation.and_grant_access!(@invitation, @user)
  visit invitation_path(@invitation)
end

Given /^"(.*?)" has been invited to the group$/ do |email|
  User.invite_and_notify!(FactoryGirl.attributes_for(:user), FactoryGirl.create(:user), @group)
end

Given /^I am a member of a group invitable by members$/ do
  @group = FactoryGirl.create :group
  @group.members_invitable_by = :members
  @group.save!
  @group.add_member! @user
end

Given /^the group is invitable by admins$/ do
  @group.members_invitable_by = 'admins'
  @group.save!
end

Given /^I am a member of a subgroup invitable by members$/ do
  @subgroup = FactoryGirl.create :group, parent: @group, members_invitable_by: "members"
  @subgroup.add_member!(@user)
end

Given /^I am a member of a subgroup invitable by admins$/ do
  @subgroup = FactoryGirl.create :group, parent: @group, members_invitable_by: "admins"
  @subgroup.add_member!(@user)
end

Given /^I am an admin of a subgroup invitable by admins$/ do
  @subgroup = FactoryGirl.create :group, parent: @group, members_invitable_by: "admins"
  @subgroup.add_admin!(@user)
end

When /^I invite "(.*?)" to the group$/ do |email|
  @current_user = User.find_by_email email
  click_on "group-add-members"
  fill_in 'user_email', with: email
  click_on 'invite'
end

When /^I visit the subgroup page$/ do
  visit group_path(@subgroup)
end

When /^I click invite people$/ do
  find("#button-container").find("#invite-new-members").click
end

When /^I select "(.*?)" from the list of members$/ do |arg1|
  user = User.find_by_name(arg1)
  find(:xpath, "//input[@value='#{user.id}']").set(true)
end

Then /^the request is approved$/ do
  @membership = Membership.last
  UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
end

Then /^they should be added to the group$/ do
  Membership.where(:user_id => User.find_by_email(@current_user.email)).size.should > 0
end

Then /^I should be notified that they are already a member$/ do
  page.should have_content("#{@current_user.email} is already in the group.")
end

Then /^I should be notified that they have been invited$/ do
  page.should have_content("An invite has been sent")
end

Then /^I should be notified that the email address is invalid$/ do
  page.should have_content("was not invited. Please check the email address is correct.")
end

Then /^"(.*?)" should not be a member of the group$/ do |email|
  Group.find_by_name(@group.name).users.find_by_email(email).should be_nil
end

Then /^I should see "(.*?)" listed in the invited list$/ do |email|
  find("#invited-users").should have_content(email)
end

Then /^I should not see the add member button$/ do
  page.should_not have_content("#group-add-members")
end

Then /^I should not see the invited user list$/ do
  page.should_not have_css("#invited-users")
end

Then /^I should see "(.*?)" in the list$/ do |email|
  find("#invite-subgroup-members").should have_content(email)
end

Then /^I should not see "(.*?)" in the list$/ do |email|
  find("#invite-subgroup-members").should_not have_content(email)
end

Then /^I should see "(.*?)" as an invited user of the subgroup$/ do |email|
  find("#invited-users").should have_content(email)
end

Then /^I should see "(.*?)" as a member of the subgroup$/ do |name|
  visit group_memberships_path(@group)
  page.should have_content(name)
end

Then /^I should get an email with subject "(.*?)"$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should =~ /Membership approved/
end

When(/^I confirm the selection$/) do
  find("#invite-to-subgroup").click
end

Then(/^"(.*?)" should receive a notification that they have been added$/) do |arg1|
  user = User.find_by_name(arg1)
  Notification.where(user_id: user.id).last.event.kind.should == 'user_added_to_group'
end

When(/^I enter "(.*?)" in the invitations field$/) do |arg1|
  fill_in "invitees", with: arg1
end

Then(/^"(.*?)" should be invited to join the subgroup$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should == [arg1]
  last_email.subject.should =~ /invited you to join/
end

Given(/^I am a coordinator of a hidden subgroup with hidden parent$/) do
  @parent_group = FactoryGirl.create :group, privacy: "hidden"
  @parent_group.add_member! @user
  @subgroup = FactoryGirl.create :group, parent: @parent_group, privacy: "hidden"
  @subgroup.add_admin! @user
end

Then(/^I should not see the invitations field$/) do
  page.should_not have_css("#invitees")
end

When(/^I visit a discussion page$/) do
  @discussion = create_discussion group: @group, author: @group_admin
  visit discussion_path(@discussion)
end

When(/^I invite "(.*?)" to join the discussion$/) do |arg1|
  fill_in "invitees", with: arg1
  click_on 'Invite people'
end

Then (/^"(.*?)" should get an invitation to join the discussion$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should == [arg1]
end

Given(/^I am invited to join a discussion$/) do
  @group_admin = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_admin! @group_admin
  @discussion = create_discussion group: @group, author: @group_admin
  @invite_people_form = InvitePeopleForm.new(recipients: ['jim@jam.com'], message_body: 'please click the invitation link below')
  InvitationService.invite_to_discussion(recipient_emails: @invite_people_form.recipients, message: @invite_people_form.message_body, discussion: @discussion, inviter: @group_admin)
end

Then(/^I should be redirected to the discussion page$/) do
  page.should have_css('body.discussions.show')
end
