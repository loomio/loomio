Given(/^I complete the group setup form$/) do
  fill_in 'name', with: "Fantastic Spinners"
  find('#complete_setup').click
end

Then(/^the group should be setup$/) do
  @group.reload
  @group.discussions.first.title.should == I18n.t('example_discussion.title')
  @group.motions.first.name.should == I18n.t('example_motion.name')
  @group.is_setup?.should be_true
end

Then(/^I should be on the group page$/) do
  page.should have_css('.groups.show')
end

When(/^I visit the group setup page$/) do
  visit setup_group_path(@group.id)
end

Then(/^I should be told that I dont have permission to set up this group$/) do
  page.should have_content(I18n.t("warning.user_not_admin", which_user: @user.name))
end

Then(/^I should be notified it has already been setup$/) do
  page.should have_content(I18n.t("error.group_already_setup"))
end

Given(/^I am an admin of a group that has not completed setup$/) do
  step 'I am an admin of a group'
  @group.update_attribute(:setup_completed_at, nil)
end

Then(/^I should be redirected to the group setup$/) do
  current_path.should == setup_group_path(@group)
end

Given(/^I am an admin of a parent group that has not completed setup$/) do
  @group = FactoryGirl.create :group
  @group.add_admin! @user
  @group.update_attribute(:setup_completed_at, nil)
end

Given(/^I am a member of a group that has not completed setup$/) do
  @group = FactoryGirl.create :group
  @group.add_member! @user
  @group.update_attribute(:setup_completed_at, nil)
end

Given(/^I am an admin of a subgroup group that has not completed setup$/) do
  @group = FactoryGirl.create :group
  @group.add_member! @user
  @subgroup = FactoryGirl.create :group, parent: @group
  @subgroup.add_admin! @user
  @subgroup.update_attribute(:setup_completed_at, nil)
end

Then(/^I should see the subgroup page$/) do
  page.should have_css(".groups.show")
end
