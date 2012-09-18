Given /^I am logged in as "(.*?)"$/ do |arg1|
  login(arg1,'password')
end

Given /^a group "(.*?)" with "(.*?)" as admin$/ do |arg1, arg2|
  @user = FactoryGirl.create(:user, :email => arg2)
  @group = FactoryGirl.create(:group, :name => arg1)
  @group.add_admin!(@user)
end

Given /^I visit create subgroup page for group named "(.*?)"$/ do |arg1|
  find("#my-groups").click_on("My groups")
  find("#my-groups").click_on(arg1)
  find("#sub-groups .sub-panel .dropdown a").click
  find("#sub-groups").click_link("Create a Sub-group +")
end


Given /^I am admin of group "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I visit create subgroup page for "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill details for the subgroup$/ do
  fill_in "group-name", :with => 'test group'
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_members"
  uncheck "group_email_new_motion"
end

When /^I click "(.*?)"$/ do |arg1|
  click_on arg1
end

Then /^I should see "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end

When /^I fill details for  public all members invite subgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_members"
end

When /^I fill details for public admin only invite subgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_admins"
end

When /^I fill details for members only all members invite subgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_members"
end

When /^I fill details for members only admin invite subgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_admins"
end

When /^I fill details for members and parent members only all members invite subgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_members"
end

When /^I fill details for members and parent members admin only invite ubgroup$/ do
  fill_create_subgroup_common
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_admins"
end

When /^I visit the group page for "(.*?)"$/ do |group_name|
  visit group_path(Group.find_by_name(group_name))
end
