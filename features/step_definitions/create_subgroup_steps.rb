When(/^I create a totally open subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  choose 'group_visible_true'
  choose 'group_private_discussions_only_false'
  check  'group_visible_to_parent_members'
  choose 'group_members_invitable_by_members'
  click_on 'group_form_submit'
end

Then(/^a totally open subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  group.description.should == 'description'
  group.should be_visible
  group.should_not be_private_discussions_only
  group.should be_visible_to_parent_members
  group.members_invitable_by.should == 'members'
end

When(/^I create a locked down subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  choose 'group_visible_false'
  choose 'group_private_discussions_only_true'
  choose 'group_members_invitable_by_admins'
  click_on 'group_form_submit'
end

Then(/^a locked down subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  group.description.should == 'description'
  group.should_not be_visible
  group.should be_private_discussions_only
  group.should_not be_visible_to_parent_members
  group.members_invitable_by.should == 'admins'
end

