Given /^an open group exists$/ do
  @group = FactoryGirl.create :group
  @group.add_admin! FactoryGirl.create :user
  @group.viewable_by = :everyone
  @group.description = "This is an *Open Group* group, which would formally have been called a 'public group'"
  @group.save!
end

Given /^a public group exists$/ do
  @group = FactoryGirl.create :group
  @group.add_admin! FactoryGirl.create :user
  @group.viewable_by = :everyone
  @group.description = "this group is public"
  @group.save!
end

Given /^a private group exists$/ do
  @group = FactoryGirl.create :group
  @group.viewable_by = :members
  @group.description = "this group is private"
  @group.save
end

Given(/^a public group exists with a Spanish\-speaking admin "(.*?)"$/) do |arg1|
  @group = FactoryGirl.create :group
  @group.viewable_by = :everyone
  @group.save
  admin = @group.admins.first
  admin.update_attribute(:language_preference, "es")
  admin.update_attribute(:email, "#{arg1}@example.org")
  admin.save
end

Given /^a public sub\-group exists$/ do
  @parent_group = FactoryGirl.create :group, :viewable_by => :everyone
  @sub_group = FactoryGirl.create :group, :parent => @parent_group,
                                  :viewable_by => :everyone
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
  @discussion.description = "this discussion should inherit privacy from it's group"
  @discussion.save
  @discussion_with_decision = FactoryGirl.create :discussion, :group => @group, :title => 'This is a discussion with decision'
  FactoryGirl.create :motion, :discussion => @discussion_with_decision
end

Given /^a public group exists that I am not a member of$/ do
  step "a public group exists"
end

Given /^I am a member of a private group$/ do
  step "a private group exists"
  @group.add_member! @user
end

Given /^a private group exists that I am not a member of$/ do
  step "a private group exists"
end

Given /^a public sub\-group exists that I am not a member of$/ do
  step "a public sub-group exists"
end

Given /^a private sub\-group exists that I am not a member of$/ do
  step "a private sub-group exists"
end

Given /^I am a member of a public sub\-group$/ do
  step "a public sub-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am a member of a private sub\-group$/ do
  step "a private sub-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am a member of a sub\-group viewable by parent\-group members$/ do
  step "a sub-group viewable by parent-group members exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am a member of a parent\-group that has a sub\-group viewable by parent\-group members$/ do
  @parent_group = FactoryGirl.create :group
  @admin_user = FactoryGirl.create :user
  @parent_group.add_admin! @admin_user
  @sub_group = FactoryGirl.create :group, :parent => @parent_group, :viewable_by => :parent_group_members
  @sub_group.add_admin! @admin_user
  @parent_group.add_member! @user
end

Given /^I am not a member of a parent\-group that has a sub\-group viewable by parent\-group members$/ do
  step "a sub-group viewable by parent-group members exists"
end

Given /^the sub\-group has discussions$/ do
  @sub_group_discussion = FactoryGirl.create :discussion, :group => @sub_group
  @sub_group_discussion_with_decision = FactoryGirl.create :discussion, :group => @sub_group, :title => 'This is a sub group discussion with decision'
  FactoryGirl.create :motion, :discussion => @sub_group_discussion_with_decision
end

When /^I visit the sub\-group page$/ do
  visit group_path(@sub_group)
end

When /^I visit the parent\-group page$/ do
  visit group_path(@parent_group)
end

Then /^I should see the group's discussions$/ do
  page.should have_content(@discussion.title)
  page.should have_content(@discussion_with_decision.title)
end

Then /^I should not see the group's discussions$/ do
  page.should_not have_content(@discussion.title)
  page.should_not have_content(@discussion_with_decision.title)
end

Then /^I should see the sub\-group's discussions$/ do
  page.should have_content(@sub_group_discussion.title)
  page.should have_content(@sub_group_discussion_with_decision.title)
end

Then /^I should not see the sub\-group's discussions$/ do
  page.should_not have_content(@sub_group_discussion.title)
  page.should_not have_content(@sub_group_discussion_with_decision.title)
end

Then /^we should make this test work$/ do
  pending "For some reason this test isn't working"
end
