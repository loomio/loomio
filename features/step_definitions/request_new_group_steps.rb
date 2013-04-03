Given /^I have discussed using Loomio with my group$/ do
end

When /^I visit the Request New Group page$/ do
  visit request_new_group_path
end

When /^I fill in the Request New Group Form$/ do
  @group_admin = "Group master Sam"
  @group_admin_email = "supreme_ruler@world.com"
  @group_country_name = "nz"
  @group_name = "The whole world"
  @group_request_sector = "business"
  @group_description = "Everyone in the entire world"
  @group_size = 90
  fill_in "group_request_admin_name", with: @group_admin
  fill_in "group_request_admin_email", with: @group_admin_email
  select(@group_country_name, from: 'group_request_country_name')
  fill_in "group_request_name", with: @group_name
  find(:css, '#group_request_sectors_business').set(true)
  fill_in "group_request_description", with: @group_description
  fill_in "group_request_expected_size", with: @group_size
end

When /^I fill in and submit the Request New Group Form$/ do
  click_on "request-new-group"
  step "I fill in the Request New Group Form"
  find("#submit-group-request").click
end

When /^I fill in and submit the Request New Group Form as a Robot$/ do
  click_on "request-new-group"
  step "I fill in the Request New Group Form"
  fill_in "group_request_robot_trap", with: "ImarobT!"
  find("#submit-group-request").click
end

When /^I fill in and submit the Request New Group Form incorrectly$/ do
  click_on "request-new-group"
  # try to submit blank form
  find("#submit-group-request").click
end

When /^I open the verification email sent to me$/ do
  open_email(@group_admin_email)
end

When /^I click the verification link$/ do
  click_first_link_in_email
end

Then /^a new Loomio group request should be created$/ do
  @group_request = GroupRequest.where(:name => @group_name).first
  @group_request.should_not be_nil
end

Then /^I should be told that my request will be reviewed shortly$/ do
  page.should have_css("body.group_requests.verify")
end

Then /^a new Loomio group request should not be created$/ do
  GroupRequest.where(:name => "The whole world").size.should == 0
end

Then /^a new Loomio group request should be created and marked as spam$/ do
  GroupRequest.first.should be_marked_as_spam
end

Then /^I should still see the Group Request Form$/ do
  page.should have_css("#new_group_request")
end

<<<<<<< HEAD
Then /^I should be told to check my inbox for a verification email$/ do
  page.should have_content("Please check your email for a verification link")
end

Then /^the group request should be marked as verified$/ do
  @group_request.reload
  @group_request.status.should == 'verified'
end

=======
>>>>>>> feature/update-group-request-page
