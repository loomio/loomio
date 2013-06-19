Given /^I have requested to start a loomio group$/ do
  @admin_email = @user ? @user.email : "test@example.org"
  @group_request = FactoryGirl.create :group_request, admin_email: @admin_email, status: 'verified'
  reset_mailer
end

Given /^the group request has been approved$/ do
  @approver = FactoryGirl.create :user
  @group_request.verify!
  setup_group = SetupGroup.new(@group_request)
  setup_group.approve_group_request(approved_by: @approver)
  setup_group.send_invitation_to_start_group!('{group_invitation_link}')
  @group = @group_request.group
end

Given /^the group request has been accepted$/ do
  step "the group request has been approved"
  @group_request.status = 'accepted'
  @group_request.save!
end

When /^I open the email sent to me$/ do
  open_email(@admin_email)
end

When /^I click the invitation link to start a new group$/ do
  click_email_link_matching(/token/)
end

When /^I choose to create an account$/ do
  @user_email = "blah@jah.com"
  click_on "create-account"
end

When /^I fill in and submit the new user form$/ do
  fill_in "user_name", with: "My name"
  fill_in "user_email", with: @admin_email
  fill_in "user_password", with: "password"
  click_on "submit"
end

When /^I choose to log in and then I submit the login form$/ do
  @user = FactoryGirl.create :user, email: @admin_email
  click_on "sign-in"
  fill_in "user_email", :with => @user.email
  fill_in "user_password", :with => @user.password
  click_on "sign-in-btn"
end

When /^I click the old format invitation link to start a new group$/ do
  visit("/groups/#{@group_request.group_id}/invitations/#{@group_request.token}")
end

Then /^I should be asked to create an account$/ do
  page.should have_content("Your request to a start a new group on Loomio has been approved!")
end

Then /^I should become the admin of the group$/ do
  @user ||= User.find_by_email(@admin_email)
  @user.is_group_admin?(@group).should == true
end

Then /^the group request should be marked as accepted$/ do
  @group_request.reload
  @group_request.should be_accepted
end

Then /^I should be notified the link is invalid$/ do
  page.should have_content('Sorry! This invitation is invalid')
end

Then /^I should be notified the invitation has already been accepted$/ do
  page.should have_content('has already been accepted.')
end
