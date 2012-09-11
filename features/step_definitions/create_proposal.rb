When /^I click create proposal$/ do
  click_link 'Create new proposal'
end

When /^fill in the proposal details$/ do
  fill_in 'motion-name', with: "Best Proposal"
  fill_in 'motion_description', with: "This is the description of the best proposal ever"
end

Then /^a new proposal is created$/ do
  Discussion.where(:name =>"Best Proposal")
end


When /^I am on a group page$/ do
  group = Group.all.first
  visit "/groups/" + group.id.to_s 
end

