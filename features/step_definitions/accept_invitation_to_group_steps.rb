Given /^I have been invited to join a loomio group and I am a new user$/ do
  @group = FactoryGirl.create :group
  @inviter = FactoryGirl.create :user
  @recipient_email = 'little@email.com'
  InvitesUsersToGroup.invite!(:recipient_emails => [@recipient_email],
                              :group => @group,
                              :inviter => @inviter)
end

Given /^I have been invited to join a loomio group and I am an existing user$/ do
  step 'I have been invited to join a loomio group and I am a new user'
end

When /^I open the email and click the invitation link$/ do
  open_email(@recipient_email)
  click_first_link_in_email
end

Then /^I should see a page that explains that my group is using Loomio to make decisions$/ do
  page.should have_css("#invitation-container")
end

Then /^I should be asked to create an account or log\-in$/ do
  page.should have_css("#create-account")
  page.should have_css("#sign-in")
end

When /^I create my user account$/ do
  @user_email = "blah@jah.com"
  click_on "create-account"
  fill_in "name", :with => "My name"
  fill_in "email", :with => @user_email
  fill_in "password", :with => "password"
  click_on "submit"
end

Then /^I should become a member of the group$/ do
  @user = User.find_by_email(@user_email) unless @user
  @group.users.include?(@user).should be_true
end

Given /^I have not received an invitation$/ do
end

When /^I visit the create account page$/ do
  visit new_user_path
end

Then /^I should be redirected to the homepage$/ do
  page.should have_css('.pages.show')
end

When /^I log in$/ do
  @user = FactoryGirl.create :user
  click_on "sign-in"
  fill_in "user_email", :with => @user.email
  fill_in "user_password", :with => "password"
  click_on "sign-in-btn"
end

Then /^I should be taken to the group page$/ do
  page.should have_content(@group.name)
end

Given /^there is an accepted invitation$/ do
  step 'I have been invited to join a loomio group and I am a new user'
  @invitation = Invitation.where(:recipient_email => @recipient_email).first
  @invitation.accepted = true
  @invitation.save!
end

Then /^I should not become a member of the group$/ do
  @group.users.include?(@user).should be_false
end

When /^I visit the invitation link$/ do
  step 'I open the email and click the invitation link'
end

Then /^I should see a message that the invitation has already been used$/ do
  page.should have_content('This invitation has already been accepted by another user')
end

Given /^I have requested to start a loomio group and the requst has been approved$/ do
  step 'I have been invited to join a loomio group and I am a new user'
end

Then /^I should become the admin of the group$/ do
  @user.is_group_admin?(@group).should == true
end

Then /^I should be taken to the group\'s demo proposal page$/ do
  page.should have_content("We should have a holiday on the moon!")
end


