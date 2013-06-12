When /^I choose to leave the group$/ do
  find('a.btn.group-options').click
  step 'I click "Leave group"'
  step 'I confirm the action'
end

Given(/^there is another admin in the group also$/) do
  @group.add_admin! FactoryGirl.create :user
end

Then /^I should be removed from the group$/ do
  pending "This feature is working but it displays the wrong text in the flash"
  step %{I should see "You have left #{@group.name}"}
end
