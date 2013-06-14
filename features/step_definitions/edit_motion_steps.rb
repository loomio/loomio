When /^I click the edit proposal button$/ do
  click_on 'edit-motion'
end

Then /^I should not see a link to edit the proposal$/ do
  page.should_not have_css("edit-motion")
end

Then /^I should see the edit proposal form$/ do
  page.should have_css("body.motions.edit")
end

When(/^I change the description$/) do
  fill_in 'motion_description', with: 'Pink popsicles'
end

When(/^I click the update button$/) do
  click_on I18n.t('motion_form.submit_update')
end

Then(/^I should see see the discussion page$/) do
  page.should have_css('body.discussions.show')
end

Then(/^I should see the updated description$/) do
  find('.current-proposal').should have_content('Pink popsicles')
end

Then(/^I should see the motion revision link$/) do
  find('.current-proposal').should have_css('#motion-revision-link')
end

Given(/^the proposal has been edited$/) do
  @original_description = @motion.description
  @motion.description = "ch-ch-ch-changes"
  @motion.save!
end

When(/^I click the motion revision link$/) do
  click_on 'motion-revision-link'
end

Then(/^I should not see the revision link$/) do
  page.should_not have_css('#motion-revision-link')
end

Then(/^I should see the revision history page$/) do
  page.should have_css('body.motions.revision_history')
end

Then(/^I should see the original version$/) do
  find('#revision-history-list').should have_content(@original_description)
end

Then(/^I should see the new version$/) do
  find('#revision-history-list').should have_content(@motion.description)
end
