Given /^an open group exists$/ do
  @group = FactoryGirl.create :group
  @group.add_admin! FactoryGirl.create :user
  @group.privacy = 'public'
  @group.description = "This is an *Open Group* group, which would formally have been called a 'public group'"
  @group.save!
end

Given /^a public group exists$/ do
  @group = FactoryGirl.create :group
  @group.add_admin! FactoryGirl.create :user
  @group.privacy = 'public'
  @group.description = "this group is public"
  @group.save!
end

Given /^a hidden group exists$/ do
  @group = FactoryGirl.create :group
  @group.privacy = 'hidden'
  @group.description = "this group is hidden"
  @group.save
end

Given(/^a public group exists with a Spanish\-speaking admin "(.*?)"$/) do |arg1|
  @group = FactoryGirl.create :group
  @group.privacy = 'public'
  @group.save
  admin = @group.admins.first
  admin.update_attribute(:selected_locale, "es")
  admin.update_attribute(:email, "#{arg1}@example.org")
  admin.save
end

Given /^a public sub\-group exists$/ do
  @parent_group = FactoryGirl.create :group, :privacy => 'public'
  @sub_group = FactoryGirl.create :group, :parent => @parent_group,
                                  :privacy => 'public'
end

Given /^a hidden sub\-group exists$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group
  @sub_group.privacy = 'hidden'
  @sub_group.save
end

Given /^a sub\-group viewable by parent\-group members exists$/ do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group, privacy: 'hidden', viewable_by_parent_members: true
  @sub_group.save
end

Given /^I am a member of a public group$/ do
  step "a public group exists"
  @group.add_member! @user
end

Given /^the group has a discussion$/ do
  @discussion = create_discussion :group => @group
  @discussion.description = "this discussion should inherit privacy from it's group"
  @discussion.save!
end

Given /^the group has discussions$/ do
  @discussion = create_discussion :group => @group
  @discussion.description = "this discussion should inherit privacy from it's group"
  @discussion.save
  @discussion_with_decision = create_discussion :group => @group, :title => 'This is a discussion with decision'
  FactoryGirl.create :motion, :discussion => @discussion_with_decision
end

Given /^a public group exists that I am not a member of$/ do
  step "a public group exists"
end

Given /^I am a member of a hidden group$/ do
  step "a hidden group exists"
  @group.add_member! @user
end

Given /^a hidden group exists that I am not a member of$/ do
  step "a hidden group exists"
end

Given /^a public sub\-group exists that I am not a member of$/ do
  step "a public sub-group exists"
end

Given /^a hidden sub\-group exists that I am not a member of$/ do
  step "a hidden sub-group exists"
end

Given /^I am a member of a public sub\-group$/ do
  step "a public sub-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Given /^I am a member of a hidden sub\-group$/ do
  step "a hidden sub-group exists"
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
  @sub_group = FactoryGirl.create :group, :parent => @parent_group, :privacy => 'hidden', :viewable_by_parent_members => true
  @sub_group.add_admin! @admin_user
  @parent_group.add_member! @user
end

Given /^I am not a member of a parent\-group that has a sub\-group viewable by parent\-group members$/ do
  step "a sub-group viewable by parent-group members exists"
end

Given /^the sub\-group has discussions$/ do
  @sub_group_discussion = create_discussion :group => @sub_group, :title => 'This is a less brittle discussion title'
  @sub_group_discussion_with_decision = create_discussion :group => @sub_group, :title => 'This is a sub group discussion with decision'
  FactoryGirl.create :motion, :discussion => @sub_group_discussion_with_decision
end

When /^I visit the sub\-group page$/ do
  visit group_path(@sub_group)
end

When /^I visit the parent\-group page$/ do
  visit group_path(@parent_group)
end

Then /^I should see the group's discussions$/ do
  page.should have_content(@discussion.title[0, 50])
  page.should have_content(@discussion_with_decision.title[0, 50])
end

Then(/^I should see the discussion title$/) do
  page.should have_content(@discussion.title)
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

Given(/^I am a member of a parent\-group that has sub\-groups I don't belong to$/) do
  @parent_group = FactoryGirl.create :group
  @parent_group.add_member! @user
  @sub_groups = []
  ['hidden', 'public'].each do |privacy|
    @sub_groups << FactoryGirl.create(:group,
                                      parent: @parent_group,
                                      privacy: privacy,
                                      viewable_by_parent_members: true)
  end
end

Given(/^those sub\-groups have discussions$/) do
  @discussions = []
  @sub_groups.each do |sub_group|
    @discussions << create_discussion(group: sub_group)
  end
end

Then(/^I should not see those sub\-groups' discussions$/) do
  @discussions.each do |discussion|
    page.should_not have_content(discussion.title)
  end
end

Given(/^I am a coordinator of a public group$/) do
  @group = FactoryGirl.create :group
  @group.add_admin! @user
  @group.privacy = 'public'
end

When(/^I set the group to hidden$/) do
  visit edit_group_path(@group)
  choose 'group_privacy_hidden'
  click_on 'group_form_submit'
end

Then(/^the group should be set to hidden$/) do
  @group.reload
  @group.privacy.should == 'hidden'
end

Given(/^I am a coordinator of a hidden group$/) do
  @group = FactoryGirl.create :group
  @group.add_admin! @user
  @group.privacy = 'hidden'
end

When(/^I set the group to public$/) do
  visit edit_group_path(@group)
  choose 'group_privacy_public'
  click_on 'group_form_submit'
end

Then(/^the group should be set to public$/) do
  @group = FactoryGirl.create :group
  @group.add_admin! @user
  @group.privacy = 'public'
end

Given(/^I am a coordinator of a hidden subgroup$/) do
  @parent_group = FactoryGirl.create :group
  @parent_group.add_member! @user
  @subgroup = FactoryGirl.create :group, parent: @parent_group
  @subgroup.add_admin! @user
end

When(/^I visit the edit subgroup page$/) do
  visit edit_group_path(@subgroup)
end

When(/^I set the subgroup to be viewable by parent members$/) do
  check 'group_viewable_by_parent_members'
  click_on 'group_form_submit'
end

Then(/^the subgroup should be viewable by parent members$/) do
  @subgroup.reload
  @subgroup.should be_viewable_by_parent_members
end

When(/^I set the group to private$/) do
  visit edit_group_path(@group)
  choose 'group_privacy_private'
  click_on 'group_form_submit'
end

Then(/^the group should be set to private$/) do
  @group.reload
  @group.privacy.should == 'private'
end

Given(/^a private group exists$/) do
  @group = FactoryGirl.create :group
  @group.privacy = 'private'
  @group.save
end

Then(/^I should not see the discussion$/) do
  page.should_not have_content(@discussion.title)
end

Then(/^I should see the group members$/) do
  page.should have_css('#users-list')
end

Then(/^I should not see previous decisions$/) do
  page.should_not have_css('#show-closed-motions')
end

Given(/^I am a member of a private group$/) do
  @group = FactoryGirl.create :group
  @group.privacy = 'private'
  @group.add_member! @user
  @group.save
end

Given(/^a private sub\-group exists$/) do
  @parent_group = FactoryGirl.create :group
  @sub_group = FactoryGirl.create :group, :parent => @parent_group
  @sub_group.privacy = 'private'
  @sub_group.save
end

Given(/^I am a member of a private sub\-group$/) do
  step "a private sub\-group exists"
  @parent_group.add_member! @user
  @sub_group.add_member! @user
end

Then(/^I should see the group title$/) do
  page.should have_content(@group.full_name)
end

Then(/^I should see the subgroup title$/) do
  page.should have_content(@sub_group.name)
end

Given(/^I am a coordinator of a non\-hidden group$/) do
  @public_group = FactoryGirl.create :group, privacy: 'public'
  @public_group.add_admin! @user
end

Given(/^the group has a public discussion$/) do
  @discussion = create_discussion group: @public_group, private: false
end

When(/^I set the group privacy to hidden$/) do
  visit edit_group_path(@public_group)
  choose 'group_privacy_hidden'
  click_on 'group_form_submit'
end

Then(/^I should see that the discussions are private$/) do
  visit discussion_path(@discussion)
  page.should have_css('.fa-lock')
end

