When(/^I visit the admin Group Requests index$/) do
  visit admin_group_requests_path
  view_screenshot
end

Given /^I am a Loomio super\-admin$/ do
  @user = FactoryGirl.create :user, :is_admin => true
end

Given /^there is a verified request to join Loomio$/ do
  @group_request = FactoryGirl.create :group_request, status: 'verified'
  reset_mailer
end

When /^I visit the Group Request in the admin panel$/ do
  visit admin_group_request_path(@group_request)
end

When /^I visit the Group Requests on the admin panel$/ do
  visit admin_group_request_path
end

When /^I click approve for a request$/ do
  click_link("Approve")
end

When /^I click defer for the request$/ do
  click_link("defer")
end

When /^I should see the send approval email page$/ do
  page.should have_content('Send Approval Email')
end

When /^I customise the approval email text$/ do
  fill_in 'Max size', with: '25'
end

When /^I click the send and approve button$/ do
  click_on 'Approve and send email'
end

When /^I edit the maximum group size$/ do
  click_link("Edit")
  fill_in "group_request_max_size", :with => 135
  click_on("Update Group request")
end

When(/^I click the send and defer button$/) do
  click_on("submit-defer-email")
end

When /^I should see the send defer email page$/ do
  page.should have_content('Send Defer Email')
end

When /^I select the date to defer until$/ do
  fill_in "group_request_defered_until", with: "2013-9-24"
end

Then /^I should no longer see the request$/ do
  page.should_not have_css "#group_request_#{@group_request.id}"
end

Then /^the group should be created$/ do
  Group.where(:name => @group_request.name).should exist
end

Then /^the group should not be created$/ do
  Group.where(:name => @group_request.name).should_not exist
end

Then /^the group request should be marked as approved$/ do
  @group_request.reload
  @group_request.should be_approved
end

Then /^the group request should be marked as defered$/ do
  @group_request.reload
  @group_request.should be_defered
  @group_request.defered_until.should_not be_nil
end

Then /^an email should be sent to the group admin with an invitation link$/ do
  open_email(@group_request.admin_email)
  @invitation = Invitation.find_by_recipient_email(@group_request.admin_email)
  current_email.should have_content(invitation_path(@invitation))
end

Then /^I should be redirected to the Group Requests page$/ do
  page.should have_css "body.admin_group_requests"
end

Then /^the maximum group size should be assigned to the group$/ do
  @group_request.reload
  @group_request.max_size.should == 135
end

Then(/^an email should be sent to the group admin explaining the defer$/) do
  open_email(@group_request.admin_email)
  current_email.subject.should have_content(I18n.t('defered_email.subject'))
end

