When /^I select the move discussion link from the discussion dropdown$/ do
  find("#options-dropdown").click
  click_on "move-discussion"
end

When /^I select the destination subgroup$/ do
  select @subgroup.name, from: 'discussion_group_id'
end

Then /^I should see the destination subgroup name in the page title$/ do
  find('.group-title').should have_content @subgroup.name
end

When /^I select the destination parent group$/ do
  select @group.name, from: 'discussion_group_id'
end

Then /^I should not see the subgroup name in the page title$/ do
  find('.group-title').should_not have_content @subgroup.name
end

When /^I click on move$/ do
  click_on 'Move discussion'
end

Then /^I try to move the discussion but I cannot see the link$/ do
  find('#discussion-options').should_not have_content 'Move discussion'
end