When /^I choose to leave the group$/ do
  step 'I click "Options"'
  step 'I click "Leave group"'
  step 'I accept popup'
end

Then /^I should be removed from the group$/ do
  @group.users.find_by_email(@user.email).should be_nil
  # step %{I should see "You have left #{@group.name}"}
end

Then /^I should be removed from the sub\-group$/ do
  @sub_group.users.find_by_email(@user.email).should be_nil
end
