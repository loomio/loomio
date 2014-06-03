Given(/^I am the logged in admin of a group$/) do
  @group = FactoryGirl.create(:group)
  @user = FactoryGirl.create(:user)
  @group.add_admin!(@user)
  login_automatically(@user)
end


Given(/^I visit the group settings page$/) do
  visit edit_group_path(@group)
end

When(/^I select listed, open, public only$/) do
  choose 'group_visible_to_public'
  choose 'group_membership_granted_upon_request'
  choose 'group_discussion_privacy_options_public_only'
  click_on 'group_form_submit'
end

Then(/^the group should be listed, open, public only$/) do
  @group.reload
  @group.should be_is_visible_to_public
  @group.membership_granted_upon_request?.should be_true
  @group.members_can_add_members.should be_true
  @group.should be_public_discussions_only
end

When(/^I select listed, by request, admins add members, public and private$/) do
  visit edit_group_path(@group)
  choose 'group_visible_to_public'
  choose 'group_membership_granted_upon_approval'
  choose 'group_members_can_add_members_false'
  choose 'group_discussion_privacy_options_public_or_private'
  click_on 'group_form_submit'
end

Then(/^the group should be listed, by request, admins add members, public and private$/) do
  @group.reload
  @group.should be_is_visible_to_public
  @group.membership_granted_upon_approval?.should be_true
  @group.members_can_add_members.should be_false
  @group.should be_public_or_private_discussions_allowed
end

When(/^I select listed, invitation only, admins add members, private only$/) do
  visit edit_group_path(@group)
  choose 'group_visible_to_public'
  choose 'group_membership_granted_upon_invitation'
  choose 'group_members_can_add_members_false'
  choose 'group_discussion_privacy_options_private_only'
  click_on 'group_form_submit'
end

Then(/^the group should be listed, by request, admins add members, private only$/) do
  @group.reload
  @group.should be_is_visible_to_public
  @group.membership_granted_upon_invitation?.should be_true
  @group.members_can_add_members.should be_false
  @group.should be_private_discussions_only
end

When(/^I select unlisted, admins add members$/) do
  visit edit_group_path(@group)
  choose 'group_visible_to_members'
  choose 'group_membership_granted_upon_invitation'
  choose 'group_members_can_add_members_false'
  choose 'group_discussion_privacy_options_private_only'
  click_on 'group_form_submit'
end

Then(/^the group should be unlisted, invitation only, admins add members, prviate discussions only$/) do
  @group.reload
  @group.should be_is_hidden_from_public
  @group.membership_granted_upon_invitation?.should be_true
  @group.members_can_add_members.should be_false
  @group.should be_private_discussions_only
end

Given(/^I am editing the settings for a subgroup$/) do
  @subgroup = FactoryGirl.create(:group, parent: @group)
  @subgroup.add_admin! @user
  visit edit_group_path(@subgroup)
end

When(/^I select visible to parent group members and save$/) do
  choose 'group_visible_to_parent_members'
  click_on 'group_form_submit'
end

Then(/^the subgroup should be visible to parent group members$/) do
  @subgroup.reload
  @subgroup.is_visible_to_parent_members?.should be_true
end

When(/^I change the group name and description$/) do
  fill_in :group_name, with: 'changed'
  fill_in :group_description, with: 'changed'
  click_on 'group_form_submit'
end

Then(/^the group name and description should be changed$/) do
  @group.reload
  @group.name.should == 'changed'
  @group.description.should == 'changed'
end


Given(/^the group has a public discussion$/) do
  @discussion = FactoryGirl.create(:discussion, private: false, group: @group)
end

When(/^I change the group to private discussions only$/) do
  choose 'group_discussion_privacy_options_private_only'
  click_on 'group_form_submit'
end

Then(/^I should have to confirm making discussions private$/) do
  # these are ignored..
end

Then(/^the discussion should be private$/) do
  @discussion.reload
  @discussion.should be_private
end
