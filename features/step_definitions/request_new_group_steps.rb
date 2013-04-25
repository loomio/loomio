Given /^I have discussed using Loomio with my group$/ do
end

When /^I visit the Request New Group page$/ do
  visit request_new_group_path
end

When /^I fill in the Request New Group Form$/ do
  @group_name = "The whole world"
  @group_size = 90
  @group_description = "Everyone in the entire world"
  @group_admin_email = "supreme_ruler@world.com"
  fill_in "group_request_name", with: @group_name
  fill_in "group_request_expected_size", with: @group_size
  fill_in "group_request_description", with: @group_description
  fill_in "group_request_admin_email", with: @group_admin_email
  choose("group_request_distribution_metric_2")
  check("group_request_sectors_metric_community")
  check("group_request_sectors_metric_other")
  fill_in "group_request_other_sectors_metric", with: "activist"
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

Then /^the group admins should receive an email with subject "(.*?)"$/ do |subject|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should include *@group.admins.map(&:email)
  last_email.subject.should =~ /New membership request/
end

Then /^a new Loomio group request should be created$/ do
  GroupRequest.where(:name => @group_name).size.should == 1
end

Then /^I should be told that my request will be reviewed shortly$/ do
  page.should have_css("body.group_requests.confirmation")
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
