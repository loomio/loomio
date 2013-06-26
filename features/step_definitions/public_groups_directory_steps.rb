Given(/^there are various public and private groups$/) do
  @public_group1 = FactoryGirl.create(:group, name: "hello world", viewable_by: 'everyone')
  5.times do
    @public_group1.add_member!(FactoryGirl.create(:user))
  end
  @public_group2 = FactoryGirl.create(:group, name: "beebly", viewable_by: 'everyone')
  @public_group3 = FactoryGirl.create(:group, name: "doodad", viewable_by: 'everyone')
  5.times do
    @public_group3.add_member!(FactoryGirl.create(:user))
  end
  @private_group = FactoryGirl.create(:group, name: "something else", viewable_by: 'members')
end

When(/^I visit the public groups directory page$/) do
  visit '/groups'
end

Then(/^I should only see public groups with 5 or more members$/) do
  find('#directory').should have_content(@public_group1.name)
  find('#directory').should_not have_content(@public_group2.name)
  find('#directory').should_not have_content(@private_group.name)
end

When(/^I search$/) do
  fill_in 'query', with: @public_group1.name
  click_on 'Search'
end

Then(/^I should only see groups that match the search$/) do
  find('#directory').should have_content @public_group1.name
  find('#directory').should_not have_content @public_group3.name
end
