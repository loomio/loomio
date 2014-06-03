When(/^I create a totally open subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  choose 'group_visible_to_public'
  choose 'group_discussion_privacy_options_public_only'
  choose 'group_members_can_add_members_true'
  click_on 'group_form_submit'
end

Then(/^a totally open subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  group.description.should == 'description'
  group.should be_is_visible_to_public
  group.should be_public_discussions_only
  group.members_can_add_members.should be_true
end

When(/^I create a locked down subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  choose 'group_visible_to_members'
  choose 'group_members_can_add_members_false'
  click_on 'group_form_submit'
end

Then(/^a locked down subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  group.description.should == 'description'
  group.should_not be_is_visible_to_public
  group.should be_private_discussions_only
  group.should_not be_is_visible_to_parent_members
  group.members_can_add_members.should be_false
end

Then(/^a visible to parent members subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  group.description.should == 'description'
  group.should be_is_visible_to_parent_members
  group.should be_parent_members_can_see_discussions
  group.members_can_add_members.should be_false
end

When(/^I create a visible to parent members subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  choose 'group_visible_to_parent_members'
  choose 'group_parent_members_can_see_discussions_true'
  choose 'group_members_can_add_members_false'
  click_on 'group_form_submit'
end

