Given(/^there is another admin in the group also$/) do
  @group.add_admin! FactoryGirl.create :user
end

And(/^I choose to leave the group$/) do
  find('.group-options-btn').click
  click_on('Leave group')
end

Then(/^I should be removed from the group$/) do
  page.should have_content ("You have left #{@group.name}")
end

And(/^I am the only coordinator of a group$/) do
  @group = FactoryGirl.create :group
  @user = @group.admins.first
  expect(@group.admins.count).to eq 1
end

Then(/^I should see that I can't leave the group$/) do
  text = (I18n.t("error.only_group_coordinator_destroy", 
    add_coordinator: group_memberships_path(@group).html_safe).
    gsub( /<[^<]+?>/ , '' ))
  page.should have_content(text)
end

When(/^I click the add another coordinator option in the flash notification$/) do
  click_link('add a new coordinator')
end

Then(/^I should be redirected to the edit memberships page$/) do
  page.should have_content(I18n.t :members)
end

Given(/^I am a member of the subgroup$/) do
  @subgroup.add_member! @user
end

Then(/^I should not be removed from the subgroup$/) do
  @subgroup.members.should include(@user)
end

Then(/^I should be removed from the subgroup$/) do
  @subgroup.members.should_not include(@user)
end
