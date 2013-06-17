Given /^a group "(.*?)" with "(.*?)" as admin$/ do |arg1, arg2|
  user = FactoryGirl.create(:user, :email => arg2)
  group = FactoryGirl.create(:group, :name => arg1)
  group.add_admin!(user)
end

Given /^a group(?: named)? "(.*?)"(?: exists)?$/ do |group_name|
  FactoryGirl.create(:group, :name => group_name)
end

Given /^I visit create subgroup page$/ do
  find("#groups").click_on("Groups")
  find("#groups").click_on(@group.name)
  click_link("subgroup-new")
end

Given /^"(.*?)" is a(?: non-admin)?(?: member)? of(?: group)? "(.*?)"$/ do |email, group_name|
  @user = User.find_by_email(email)
  if !@user
    @user = FactoryGirl.create(:user, :name => email.split("@").first, :email => email)
  end
  group = Group.find_by_name(group_name)
  group ||= FactoryGirl.create(:group, :name => group_name)
  group.add_member!(@user)
end

Given /^"(.*?)" is an admin of(?: group)? "(.*?)"$/ do |email, group_name|
  user = User.find_by_email(email)
  if !user
    user = FactoryGirl.create(:user, :email => email)
  end
  group = Group.find_by_name(group_name)
  group ||= FactoryGirl.create(:group, :name => group_name)
  group.add_admin!(user)
end

Given /^I am an admin of a group$/ do
  @group = FactoryGirl.create :group
  @group.add_admin! @user
end

Given /^I am a member of a group$/ do
  @group = FactoryGirl.create :group
  @group.add_member! @user
end

Given /^I am an admin of the subgroup$/ do
  @subgroup = FactoryGirl.create :group, parent: @group
  @subgroup.add_admin! @user
end

Given /^"(.*?)" is a member of the group$/ do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            password: 'password'
  @group.add_member! user
end

Given(/^"(.*?)" is a Spanish\-speaking member of the group$/) do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            password: 'password'
  user.update_attribute(:language_preference, "es")
  @group.add_member! user
end

Given /^"(.*?)" is not a member of the group$/ do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            password: 'password'
end

Given /^"(.*?)" is a member of the subgroup$/ do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            password: 'password'
  @subgroup.add_member! user
end

Then /^(?:I|they) should be taken to the group page$/ do
  page.should have_content(@group.name)
end

Given /^the group has a discussion with a decision$/ do
  @discussion = FactoryGirl.create :discussion, :group => @group
  @motion = FactoryGirl.create :motion, :discussion => @discussion
end

Given /^there is a discussion in the group$/ do
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Given /^there is a discussion in a public group$/ do
  @group = FactoryGirl.create :group, :viewable_by => :everyone
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Given /^there is a discussion in a private group$/ do
  @group = FactoryGirl.create :group, :viewable_by => :members
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Given /^there is a discussion in a group I belong to$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
  @group.add_member! @user
end

Given /^the subgroup has a discussion$/ do
  @discussion = FactoryGirl.create :discussion, :group => @subgroup
end

When /^I fill details for the subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_members"
end

When /^I fill details for public all members invite subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_members"
  click_on 'group_form_submit'
end

When /^I fill details for public admin only invite subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_everyone"
  choose "group_members_invitable_by_admins"
end

When /^I fill details for members only all members invite subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_members"
end

When /^I fill details for members only admin invite subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_admins"
end

When /^I fill details for members and parent members only all members invite subgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_members"
end

When /^I fill details for members and parent members admin only invite ubgroup$/ do
  fill_in "group_name", :with => 'test group'
  choose "group_viewable_by_members"
  choose "group_members_invitable_by_admins"
end

When /^I visit the group page for "(.*?)"$/ do |group_name|
  visit group_path(Group.find_by_name(group_name))
end

Then /^a new sub-group should be created$/ do
  Group.where(:name=>"test group").should exist
end

Then /^I should not see the list of invited users$/ do
  page.should_not have_css('#invited-users')
end

Then /^I email the group members$/ do
  find('#group-member-options').click()
  click_on "Email group members"
  fill_in "group_email_subject", :with => "Message to group"
  fill_in "group_email_body", :with => "Y'all are great"
  click_on "Send email"
end

Then /^memberships should get an email with subject "(.*?)"$/ do |subject|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should =~ /Message to group/
end

Given /^the group has a subgroup$/ do
  @subgroup = FactoryGirl.create(:group, parent: @group)
end

Given /^the group has a subgroup I am an admin of$/ do
  @subgroup = FactoryGirl.create(:group, parent: @group)
  @subgroup.add_admin!(@user)
end

Then /^the group has another subgroup with a discussion I am an admin of$/ do
  @subgroup1 = FactoryGirl.create(:group, parent: @group)
  @subgroup1.add_admin!(@user)
  @discussion = FactoryGirl.create :discussion, :group => @subgroup1
end
