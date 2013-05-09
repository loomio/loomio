Given /^I am on the discussion page$/ do
  visit discussion_path(@discussion)
end

When /^I visit the discussion page$/ do
  visit discussion_path(@discussion)
end

Then /^I should see the discussion$/ do
  find('#activity-list')
end

Then /^I should not see discussion options dropdown$/ do
  page.should_not have_css('#options-dropdown')
end

