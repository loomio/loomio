Given /^a public group exists$/ do
  @group = FactoryGirl.create :group
  @group.viewable_by = :everyone
  @group.save
end

Given /^a private group exists$/ do
  @group = FactoryGirl.create :group
  @group.viewable_by = :members
  @group.save
end

Given /^a public sub\-group exists$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group
  @sub_group.viewable_by = :everyone
  @sub_group.save
end

Given /^a private sub\-group exists$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group
  @sub_group.viewable_by = :members
  @sub_group.save
end

Given /^a sub\-group viewable by parent\-group members exists$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group
  @sub_group.viewable_by = :parent_group_members
  @sub_group.save
end

Given /^I am a member of a public group$/ do
  step "a public group exists"
  @group.add_member! @user
end

Given /^the group has discussions$/ do
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Then /^I should see the group's discussions$/ do
  page.should have_content(@discussion.title)
end

Given /^I am not a member of a public group$/ do
  step "a public group exists"
end

Given /^I am a member of a private group$/ do
  step "a private group exists"
  @group.add_member! @user
end

Given /^I am not a member of a private group$/ do
  step "a private group exists"
end

Then /^I should not see the group's discussions$/ do
  page.should_not have_content(@discussion.title)
end

Given /^I am a member of a public sub\-group$/ do
  step "a public sub-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^the sub\-group has discussions$/ do
  @sub_group_discussion = FactoryGirl.create :discussion, :group => @sub_group
end

When /^I visit the sub\-group page$/ do
  visit group_path(@sub_group)
end

Then /^I should see the sub\-group's discussions$/ do
  page.should have_content(@sub_group_discussion.title)
end

Given /^I am not a member of a public sub\-group$/ do
  step "a public sub-group exists"
end

Given /^I am a member of a private sub\-group$/ do
  step "a private sub-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am not a member of a private sub\-group$/ do
  step "a private sub-group exists"
end

Then /^I should not see the sub\-group's discussions$/ do
  page.should_not have_content(@sub_group_discussion.title)
end

Given /^I am a member of a sub\-group viewable by parent\-group members$/ do
  step "a sub-group viewable by parent group members exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am a member of a parent\-group that has a sub\-group viewable by parent\-group members$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group, :viewable_by => :parent_group_members
  @parent_group.add_member! @user
end
