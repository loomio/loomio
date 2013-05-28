Then /^the group admins should receive an email with subject "(.*?)"$/ do |subject|
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should include *@group.admins.map(&:email)
  last_email.subject.should match(subject)
end

Given(/^I am an admin of a group that has a membership request$/) do
  @group = FactoryGirl.create(:group)
  @group.add_admin!(@user)
  @membership = @group.add_request!(FactoryGirl.create(:user))
end

Given(/^I am on the group page$/) do
  visit group_path(@group)
end

When(/^I approve the membership request$/) do
  click_on "approve"
  click_on "confirm-action"
end

Then(/^the request should be approved$/) do
  @membership.reload.should be_member
end
