Given /^I have been invited to join a loomio group and I am a new user$/ do
  pending
  @group = FactoryGirl.create :group
  @inviter = FactoryGirl.create :user
  InvitesUsersToGroup.invite!(:recipient_emails => ['little@email.com'], 
                              :group => @group,
                              :inviter => @inviter)
end

Given /^I have been invited to join a loomio group and I am an existing user$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I click the invitation link$/ do
  click_first_link_in_email
end

Then /^I should see a page that explains that my group is using Loomio to make decisions$/ do
  page.should have_css("#invitation-body")
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

When /^I visit the create account page when$/ do
  visit new_user_path
end

Then /^I should be redirected to the homepage$/ do
  page.should have_css('.landing')
end

When /^I log in$/ do
  @user = FactoryGirl.create :user
  click_on "sign-in"
  fill_in "email", :with => @user.email
  fill_in "password", :with => "password"
  click_on "sign-in-btn"
end

Then /^I should be taken to the group page$/ do
  page.should have_content(@group.name)
end

Then /^I should be taken to the group\'s demo proposal page$/ do
  page.should have_content("We should have a holiday on the moon!")
end


