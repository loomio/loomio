def make_private_group
  @private_group = FactoryGirl.create(:group, visible_to: 'members', discussion_privacy_options: 'private_only')
  @private_group.add_member!(@other_user)
end

Given /^I am in one of the same groups as another user$/ do
  @group = FactoryGirl.create(:group, visible_to: 'public')
  @group.add_member!(@user)
  @other_user = FactoryGirl.create(:user)
  @group.add_member!(@other_user)
  make_private_group
end

Given /^I am not in any of the same groups as another user$/ do
  @group = FactoryGirl.create(:group, visible_to: 'public')
  @group.add_member!(@user)
  @other_user = FactoryGirl.create(:user)
  make_private_group
end

Given /^another user exists$/ do
  @other_user = FactoryGirl.create(:user)
  make_private_group
end

When /^I visit the other user's profile page$/ do
  visit(user_path(@other_user))
end

Then /^I should see the other user's profile information$/ do
  page.should have_css(".users.show")
  page.should have_content(@other_user.email)
end

Then /^I should not see the other user's profile information$/ do
  page.should_not have_css(".users.show")
  page.should_not have_content(@other_user.email)
end

Then(/^I should see the other user's public groups$/) do
  page.should have_content(@group.full_name)
  page.should_not have_content(@private_group.full_name)
end

Then(/^I should not see any group the other user is in$/) do
  page.should_not have_css("#user-groups-list")
end
