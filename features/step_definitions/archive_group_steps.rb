When(/^I archive my group$/) do
  find('#group-options').click
  click_on('De-activate group')
  click_on('confirm-action')
end

Then(/^my group should be archived$/) do
  page.should have_content(I18n.t('success.group_archived'))
  page.should_not have_content(@group.name)
end
