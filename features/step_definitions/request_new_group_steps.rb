Given /^I have discussed using Loomio with my group$/ do
end

When /^(?:I|they) visit the Request New Group page$/ do
  visit request_new_group_path
end

When /^I fill in the Request New Group Form$/ do
  @group_name = "The whole world"
  @group_description = "It's in our hands"
  @group_size = 90
  @group_admin = "Group master Sam"
  @group_admin_email = "supreme_ruler@world.com"
  fill_in "group_request_name", with: @group_name
  fill_in "group_request_description", with: @group_description
  fill_in "group_request_expected_size", with: @group_size
  fill_in "group_request_admin_name", with: @group_admin
  fill_in "group_request_admin_email", with: @group_admin_email
  choose("group_request_cannot_contribute_false")
end

When /^(?:I|they) fill in and submit the Request New Group Form$/ do
  step "I fill in the Request New Group Form"
  find("#submit-group-request").click
end

When /^I fill in and submit the Request New Group Form as a Robot$/ do
  step "I fill in the Request New Group Form"
  fill_in "group_request_robot_trap", with: "ImarobT!"
  find("#submit-group-request").click
end

When /^I fill in and submit the Request New Group Form incorrectly$/ do
  # try to submit blank form - validations prevent form from submiting
  # find("#submit-group-request").click
end

When /^I open the verification email sent to me$/ do
  open_email(@group_admin_email)
end

When /^I click the verification link$/ do
  step 'I click the third link in the email'
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

Then /^I should be told to check my inbox for a verification email$/ do
  page.should have_content("Please check your email for a verification link")
end

Then /^the group request should be marked as verified$/ do
  @group_request.reload
  @group_request.status.should == 'verified'
end
