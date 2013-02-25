When /^I click the delete button on a post$/ do
  click_link 'Delete'
end

And /^I accept the popup to confirm$/ do
  find('#confirm-action').click()
end

Then /^I should no longer see the post in the discussion$/ do
  find('#activity-feed').should_not have_content('Test comment')
end

Then /^I should not see the delete link on another users comment$/ do
  find('#activity-feed').should_not have_content('Delete')
end