Given(/^there are various public and private groups$/) do
  @public_group = FactoryGirl.create(:group, name: 'public bears', viewable_by: 'everyone')
  @public_group1 = FactoryGirl.create(:group, name: 'red eels', viewable_by: 'everyone')
  @private_group = FactoryGirl.create(:group, name: 'blue bears', viewable_by: 'members')
end

When(/^I visit the Loomio homepage$/) do
  visit '/'
end

When(/^I click the link to the public groups directory$/) do
  find('#public-groups').click()
end

When(/^I visit the public groups directory page$/) do
  visit '/groups'
end

When(/^I type part of the group name I am looking for into the search box$/) do
  fill_in 'query', with: 'bear'
  click_on 'Search'
end

Then(/^I should only see groups that match my search in the list$/) do
  find('#directory').should have_content @public_group.name
  find('#directory').should_not have_content @public_group1.name
end

Then(/^I should see the public groups directory page$/) do
  page.should have_content('Public groups')
end

Then(/^I should not see private groups$/) do
  find('#directory').should_not have_content @private_group.name
end
