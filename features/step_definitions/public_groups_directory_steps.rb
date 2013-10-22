Given(/^there are various public and private groups$/) do
  @public_group = FactoryGirl.create(:group, name: "lil", viewable_by: 'everyone')
  @public_group.add_member!(FactoryGirl.create(:user))
  @public_group2 = FactoryGirl.create(:group, name: "massive", viewable_by: 'everyone')
  20.times do
    @public_group3 = FactoryGirl.create(:group, name: "littler", viewable_by: 'everyone')
  end
  2.times do
    @public_group2.add_member!(FactoryGirl.create(:user))
  end
  @private_group = FactoryGirl.create(:group, name: "something else", viewable_by: 'members')
  @featured_group = FactoryGirl.create(:group, name: "lumpy group", viewable_by: 'everyone')
end

When(/^I visit the public groups directory page$/) do
  visit '/groups'
end

Then(/^I should see all public groups sorted by popularity$/) do
  find(".selector-list a:first-child").should have_content @public_group2.name
end

When(/^I search for a group$/) do
  fill_in 'query', with: @public_group.name
  find('.submit-search').click
end

Then(/^I should see groups that match the search$/) do
  find('.public-groups-container').should have_content @public_group.name
  find('.public-groups-container').should_not have_content @public_group2.name
end

When(/^I see the featured groups$/) do
  page.should have_css(".featured")
  find('.public-groups-container').should_not have_content @featured_group.name
end

When(/^I see featured groups separated from the list of groups$/) do
    page.should have_css(".featured")
    find('.public-groups-container').should_not have_content @featured_group.name
end

When(/^I click on the next page of results$/) do
  find(".pagination .next_page a").click
end

Then(/^I should not see the featured groups$/) do
  page.should_not have_css(".featured")
end

When(/^I click the alphabetise icon$/) do
  find('.sort-by-alphabet-icon').click
end

When(/^I click the alphabetise icon again$/) do
  find('.sort-by-alphabet-icon-desc').click
end

Then(/^I should see the list alphabetically sorted$/) do
  find(".selector-list a:first-child").should have_content @public_group.name
end

Then(/^I should see the list sorted in reverse$/) do
  find(".selector-list a:first-child").should have_content @public_group2.name
end

