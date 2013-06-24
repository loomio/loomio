Given(/^I belong to (\d+) groups$/) do |arg1|
  @red_group = FactoryGirl.create(:group, name: 'red')
  @blue_group = FactoryGirl.create(:group, name: 'blue')
  @red_group.add_member!(@user)
  @blue_group.add_member!(@user)
end

When(/^I visit the inbox preferences$/) do
  visit inbox_preferences_path
end

Then(/^I should see the groups I belong to$/) do
  page.should have_content(@red_group.name)
  page.should have_content(@blue_group.name)
end
