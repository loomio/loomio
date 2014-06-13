Given(/^there are some groups in categories$/) do
  @blue = Category.create name: 'blue'
  @green = Category.create name: 'green'

  @hidden_group = FactoryGirl.create :group, category: @green, is_visible_to_public: false
  @blue_group = FactoryGirl.create :group, category: @blue
  @green_group = FactoryGirl.create :group, category: @green
  @search_group = FactoryGirl.create :group
end

When(/^I visit the explore page$/) do
  visit explore_path
end

Then(/^I should see the categoried groups$/) do
  page.should have_content 'Blue'
  page.should have_content @blue_group.name
end

When(/^I search for a group on the explore page$/) do
  visit search_explore_path(query: @search_group.name)
end

Then(/^I should see the explore search results$/) do
  page.should have_content @search_group.name
end

When(/^I visit an explore category$/) do
  visit category_explore_path(id: @green.id)
end

Then(/^I should see the public groups in that category$/) do
  page.should have_content @green_group.name
end

Then(/^I should not see the hidden groups in that category$/) do
  page.should_not have_content @hidden_group.name
end
