When /^I choose to leave the group$/ do
  find('#group-options').click
  step 'I click "Leave group"'
  step 'I confirm the action'
end

Given(/^there is another admin in the group also$/) do
  @group.add_admin! FactoryGirl.create :user
end

Then /^I should be removed from the group$/ do
  page.should have_content ("You have left #{@group.name}")
end
