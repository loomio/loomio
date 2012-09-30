Given /^I am an admin of the group$/ do
  m = Membership.last
  m.access_level = "admin"
  m.save
end

When /^I visit the group settings page$/ do
  visit "/groups/" + Group.first.id.to_s + "/edit"
end

When /^I update the settings to public$/ do
  choose 'group_viewable_by_everyone'
end

When /^I update the settings to members only$/ do
  choose 'group_viewable_by_members'
end

When /^I update the group name$/ do
  fill_in 'group-name', with: "Second Test Group"
end

Then /^the group name is changed$/ do
  Group.where(:name=>"Second Test Group").size > 0
end

Then /^the group should be public$/ do
  Group.where(:name=>"New Test Group", :viewable_by=>"everyone").size > 0
end

Then /^the group should be private$/ do
  Group.where(:name=>"New Test Group", :viewable_by=>"members").size > 0
end

Given /^I am a member of the group$/ do
  m = Membership.last
  m.access_level = "member"
  m.save
end

Then /^I should not have access to group settings of "(.*?)"$/ do |group|
  visit "/groups/" + Group.find_by_name(group).id.to_s + "/edit"
  page.should have_content('Access denied')
end

When /^I update the invitations to allow all members$/ do
  choose 'group_members_invitable_by_members'
end

Then /^all members should be able to invite other users$/ do
  Group.where(:name=>"New Test Group", :members_invitable_by=>"members").size > 0
end

When /^I update the invitations to allow only admin$/ do
  choose 'group_members_invitable_by_admins'
end

Then /^only admin should be able to invite other users$/ do
  Group.where(:name=>"New Test Group", :members_invitable_by=>"admins").size > 0
end
