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
  @user = User.find_by_email(@user_email)
  @group.users.include?(@user).should be_true
end

Then /^I should be taken to the group's demo proposal page$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have been sent an invitation to join a Loomio group$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be asked to create an account or log in$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I log in$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be taken to the group page$/ do
  pending # express the regexp above with the code you wish you had
end

