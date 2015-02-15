When(/^I create a totally open subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  click_on 'Next'
  choose 'group_visible_to_public'
  choose 'group_discussion_privacy_options_public_only'
  click_on 'Next'
  click_on 'group_form_submit'
end

Then(/^a totally open subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  expect(group.description).to eq 'description'
  group.should be_is_visible_to_public
  group.should be_public_discussions_only
end

When(/^I create a locked down subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  click_on 'Next'
  choose 'group_visible_to_members'
  click_on 'Next'
  click_on 'group_form_submit'
end

Then(/^a locked down subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  expect(group.description).to eq 'description'
  group.should_not be_is_visible_to_public
  group.should be_private_discussions_only
  group.should_not be_is_visible_to_parent_members
end

Then(/^a visible to parent members subgroup should be created$/) do
  group = Group.find_by_name('subgroup')
  expect(group.description).to eq 'description'
  group.should be_is_visible_to_parent_members
  group.should be_parent_members_can_see_discussions
end

When(/^I create a visible to parent members subgroup$/) do
  fill_in 'group_name', with: 'subgroup'
  fill_in 'group_description', with: 'description'
  click_on 'Next'
  choose 'group_visible_to_parent_members'
  choose 'group_parent_members_can_see_discussions_true'
  click_on 'Next'
  click_on 'group_form_submit'
end

