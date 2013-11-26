Given(/^there are various public and private groups$/) do
  @public_group = FactoryGirl.create(:group, privacy: 'public', memberships_count: 3)
  @public_group2 = FactoryGirl.create(:group, privacy: 'public', memberships_count: 5)
  @private_group = FactoryGirl.create(:group, privacy: 'secret')
end

Then(/^I should see the featured groups$/) do
  page.should have_css(".featured-row")
end

When(/^I visit the public groups directory page$/) do
  visit '/groups'
end

Then(/^I should see all public groups sorted by popularity$/) do
  find(".selector-list a:first-child").should have_content @public_group2.name
  find('.public-groups-container').should_not have_content @private_group
end

When(/^I search for a group$/) do
  fill_in 'query', with: @public_group.name
  find('.submit-search').click
end

Then(/^I should see groups that match the search$/) do
  find('.public-groups-container').should have_content @public_group.name
  find('.public-groups-container').should_not have_content @public_group2.name
end
