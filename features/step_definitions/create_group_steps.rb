When /^I click create group$/ do
  visit "/groups/new"
end

When /^I fill in the group details$/ do
  fill_in 'group-name', with: "New Test Group"
  click_on 'update-group'
end

Then /^a new group should be created$/ do
  Group.where(:name=>"New Test Group").size > 0
end

Given /^a new group is created$/ do
  visit "/groups/new"
  fill_in 'group-name', with: "New Test Group"
  click_on 'update-group'
  Group.where(:name=>"New Test Group").size > 0
end