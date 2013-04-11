Given(/^there is a group$/) do
  @group = FactoryGirl.create(:group)
end

Given(/^I am an admin of that group$/) do
  @group_admin = FactoryGirl.create(:user)
  @group.add_admin! @group_admin
end

When(/^I invite "(.*?)" to join the group$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^"(.*?)" should get an invitation to join the group$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
