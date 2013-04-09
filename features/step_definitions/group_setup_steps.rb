Given /^I visit the group setup wizard for that group$/ do
  visit setup_group_path(@group.id)
end

Then /^I should see the group setup wizard$/ do
  page.should have_content('Set up your group')
end

When /^I click the next button$/ do
  find('#next').click
end

When /^I click the prev button$/ do
  find('#prev').click
end

Then /^I should see the setup group tab$/ do
  find('.tab-content').should have_css('#group-tab.active')
end

Then /^I should see the setup discussion tab$/ do
  find('.tab-content').should have_css('#discussion-tab.active')
end

Then /^I should see the setup decision tab$/ do
  find('.tab-content').should have_css('#motion-tab.active')
end

Then /^I should see the setup invites tab$/ do
  find('.tab-content').should have_css('#invite-tab.active')end
end