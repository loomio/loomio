When /^I select the move discussion link from the discussion dropdown$/ do
  find("#options-dropdown").click
  click_on "move-discussion"
end

When /^I select the destination subgroup$/ do
  view_screenshot
  p @subgroup.full_name
  p @user.groups.map(&:full_name)
  select @subgroup.full_name, from: 'destination_group_id'
end

Then /^I should see the destination subgroup name in the page title$/ do
  find('.group-title').should have_content @subgroup.name
end

When /^I select the destination parent group$/ do
  select @group.name, from: 'discussion_group_id'
end

Then /^I should not see the subgroup name in the page title$/ do
  find('.group-title').should_not have_content @subgroup.name
end

When /^I click on move$/ do
  click_on 'Move discussion'
end

Then /^I try to move the discussion but I cannot see the link$/ do
  find('#discussion-options').should_not have_content 'Move discussion'
end

Given(/^I am an admin of a group with a public discussion$/) do
  @group = FactoryGirl.create :group
  @discussion = create_discussion group: @group, private: false, title: "Everyone should know i hate gummy bears"
  @group.add_admin! @user
end

When(/^I select the destination hidden group$/) do
  select @subgroup.name, from: 'discussion_group_id'
end

Then(/^I should see an alert telling me that the discussion will be changed to private$/) do
  pending # express the regexp above with the code you wish you had
end
