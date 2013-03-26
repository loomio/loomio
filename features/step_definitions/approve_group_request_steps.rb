Given /^I am a Loomio super\-admin$/ do
  @user = FactoryGirl.create :user, :is_admin => true
end

Given /^there is a verified request to join Loomio$/ do
  @group_request = FactoryGirl.create :group_request, status: 'verified'
  reset_mailer
end

When /^I visit the Group Requests page on the admin panel$/ do
  visit admin_group_requests_path
end

When /^I click approve for a request$/ do
  click_link("approve_group_request_#{@group_request.id}")
end

When /^I click defer for the request$/ do
  click_link("defer_group_request_#{@group_request.id}")
end

When /^I should see the send approval email page$/ do
  page.should have_content('Send Approval Email')
end

When /^I customise the approval email text$/ do
  fill_in 'message_body', with: 'Lovely group'
  fill_in 'Max size', with: '25'
end

When /^I click the send and approve button$/ do
  click_on 'Approve and send email'
end

When /^I edit the maximum group size$/ do
  @max_size = 135
  click_link("Edit")
  fill_in "group_request_max_size", :with => @max_size
  click_on("Update Group request")
  click_link("Group Requests")
end

When /^I should see the send defer email page$/ do
  page.should have_content('Send Defer Email')
end

When /^I select the date to defer until$/ do
  fill_in "group_request_defered_until", with: "2013-3-24"
end

When /^I click the send and defer button$/ do
  click_on 'Defer and send email'
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

Then /^the time the request was approved should be recorded$/ do
  @group_request.reload
  @group_request.approved_at.should_not be_nil
end

Then /^the group request should be marked as defered$/ do
  @group_request.reload
  @group_request.should be_defered
end

Then /^an email should be sent to the group admin containing a link to start the new group$/ do
  open_email(@group_request.admin_email)
  current_email.should have_content(start_new_group_group_request_url(@group_request, token: @token))
end

Then /^I should be redirected to the Group Requests page$/ do
  page.should have_css "body.admin_group_requests"
end

Then /^the maximum group size should be assigned to the group$/ do
  Group.where(:name => @group_request.name).first.max_size.should == @max_size
end



