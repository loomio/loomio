When(/^I archive my group$/) do
  find('.group-options-btn').click
  click_on('De-activate group')
end

Then(/^my group should be archived$/) do
  page.should have_content(I18n.t('success.group_archived'))
  page.should_not have_content(@group.name)
end

Then(/^group discussions should be removed from the dashboard$/) do
  page.should_not have_content(@discussion.title)
end

Then(/^I should not be able to view specific discussions$/) do
  visit discussion_path(@discussion)
  page.should_not have_content(@discussion.title)
end
