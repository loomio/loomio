Given /^a group "(.*?)" with "(.*?)" as admin$/ do |arg1, arg2|
  user = FactoryGirl.create(:user, :email => arg2)
  group = FactoryGirl.create(:group, :name => arg1)
  group.add_admin!(user)
end

Given /^a group(?: named)? "(.*?)"(?: exists)?$/ do |group_name|
  FactoryGirl.create(:group, :name => group_name)
end

Given /^I visit create subgroup page for group named "(.*?)"$/ do |arg1|
  find("#groups").click_on("Groups")
  find("#groups").click_on(arg1)
  click_link("subgroup-new")
end

Given /^"(.*?)" is a(?: non-admin)?(?: member)? of(?: group)? "(.*?)"$/ do |email, group|
  @user = User.find_by_email(email)
  if !user 
    @user = FactoryGirl.create(:user, :name => email.split("@").first, :email => email)
  end 
  Group.find_by_name(group).add_member!(@user)
end

Given /^"(.*?)" is a[n]? admin(?: member)? of(?: group)? "(.*?)"$/ do |email, group|
  user = User.find_by_email(email)
  if !user 
    user = FactoryGirl.create(:user, :email => email)
  end 
  Group.find_by_name(group).add_admin!(user)
end

When /^I fill details for the subgroup$/ do
  fill_in "group-name", :with => 'test group'
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_members"
  uncheck "group_email_new_motion"
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
