Given /^I am a Loomio super\-admin$/ do
  @user = FactoryGirl.create :user, :is_admin => true
end

Given /^there is a request to join Loomio$/ do
  @group_request = FactoryGirl.create :group_request
end

When /^I visit the Group Requests page on the admin panel$/ do
  visit admin_group_requests_path
end

Then /^I should see the request$/ do
  page.should have_content @group_request.name
end

When /^I approve approve the request$/ do
  click_link("approve_group_request_#{@group_request.id}")
end

Then /^the group should be created$/ do
  Group.where(:name => @group_request.name).should exist
end

Then /^an invitation email should be sent to the admin$/ do
  open_email(@group_request.admin_email,
     :with_subject => "Invitation to join Loomio: #{@group_request.name}")
end

Then /^I should be redirected to the Group Requests page$/ do
  page.should have_css "body.admin_group_requests"
end

