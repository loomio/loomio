Given(/^I visit the group settings page for "(.*?)"$/) do |arg1|
  visit edit_group_path(Group.find_by_name(arg1))
end

When(/^I make the group as public as possible$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the group should be visible, default public, members invite$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I make the group as secret and locked down as possible$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the group should be hidden, default private, admins invite$/) do
  pending # express the regexp above with the code you wish you had
end


When(/^I am not an admin and I access the group settings page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I see I don't have permission to do this$/) do
  pending # express the regexp above with the code you wish you had
end

