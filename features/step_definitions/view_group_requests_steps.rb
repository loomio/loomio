Given /^there are many group requests$/ do
  @unapproved_group_request = FactoryGirl.create :group_request, status: :awaiting_approval
  @approved_group_request = FactoryGirl.create :group_request, status: :approved
  @accepted_group_request = FactoryGirl.create :group_request, status: :accepted
  @group_requests = [@unapproved_group_request, @approved_group_request, @accepted_group_request]
end

When /^I click to see approved group requests$/ do
  find("li.scope.approved a").click
end

When /^I click to see accepted group requests$/ do
  find("li.scope.accepted a").click
end

Then /^I should only see the unapproved group requests$/ do
  page.should have_css "#group_request_#{@unapproved_group_request.id}"
  page.should_not have_css "#group_request_#{@approved_group_request.id}"
  page.should_not have_css "#group_request_#{@accepted_group_request.id}"
end

Then /^I should only see the approved group requests$/ do
  page.should have_css "#group_request_#{@approved_group_request.id}"
  page.should_not have_css "#group_request_#{@unapproved_group_request.id}"
  page.should_not have_css "#group_request_#{@accepted_group_request.id}"
end

Then /^I should only see the accepted group requests$/ do
  page.should have_css "#group_request_#{@accepted_group_request.id}"
  page.should_not have_css "#group_request_#{@unapproved_group_request.id}"
  page.should_not have_css "#group_request_#{@approved_group_request.id}"
end
