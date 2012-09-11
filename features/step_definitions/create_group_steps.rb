When /^I click create group$/ do
  visit "/groups/new"
end

When /^I fill in the group details$/ do
  fill_in 'group-name', with: "New Test Group"
  click_on 'update-group'
end

Then /^a new group is created$/ do
  Group.where(:name=>"New Test Group").size > 0
end