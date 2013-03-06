Given /^I am on the discussion page$/ do
  visit discussion_path(@discussion)
end

When /^I visit the discussion page$/ do
  step 'I am on the discussion page'
end

Then /^I should see the discussion$/ do
  find('#activity-list')
end
