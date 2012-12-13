When /^I choose to leave the group$/ do
  step 'I click "Options"'
  step 'I click "Leave group"'
  step 'I accept popup'
end

Then /^I should be removed from the group$/ do
  step %{I should see "You have left #{@group.name}"}
end