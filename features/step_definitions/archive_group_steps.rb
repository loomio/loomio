When(/^I archive my group$/) do
  click_on('group-options-btn') 
  click_on('De-activate group')
  click_on('confirm-action')
end

Then(/^my group should be archived$/) do
  page.should have_content(I18n.t('success.group_archived'))
end
