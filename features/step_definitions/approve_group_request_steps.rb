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
  find("#group_request_#{@group.id}").click_link("approve")
end

Then /^the group should be created$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^invitation links should be sent to every email address$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be redirected to the Group Requests page$/ do
  pending # express the regexp above with the code you wish you had
end

