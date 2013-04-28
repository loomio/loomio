Given /^there is proposal activity on the discussion$/ do
  user = FactoryGirl.create :user
  @vote = FactoryGirl.create :vote, :statement => "I like it!", :motion => @motion, :user => user
end

Given /^I see proposal activity on the discussion$/ do
  find("#graph_#{@motion.id}").should have_css(".activity-count")
  page.should have_css(".activity-count")
end

When /^I click on the mini\-pie graph for the discussion$/ do
  pending
  find("#graph_#{@motion.id}").click
end

When /^there is futher activity since I clicked the graph$/ do
  user = FactoryGirl.create :user
  @vote1 = FactoryGirl.create :vote, :statement => "I still like it!", :motion => @motion, :user => user
end

When /^I refresh the page and click on the mini\-pie graph for the discussion again$/ do
  pending
  step %{I visit the group page}
  step %{I click on the mini-pie graph for the discussion}
end

Then /^I should see a summary of the proposal's activity$/ do
  pending ' this looks like a mental spec'
  page.should have_content(@vote.statement)
end

Then /^the proposal activity count should clear for that discussion$/ do
  find("#graph_#{@motion.id}").should_not have_css(".activity-count")
end

Then /^I should not see any new activity for that discussion$/ do
  step %{the proposal activity count should clear for that discussion}
end

Then /^I should only see the new activity for the proposal$/ do
  pending ' this looks like a mental spec'
  page.should have_content(@vote1.statement)
  page.should_not have_content(@vote.statement)
end

Then /^I should still see the proposal activity count for that discussion$/ do
  step %{I see proposal activity on the discussion}
end
