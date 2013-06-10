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

Given(/^the group is already setup$/) do
  @group.setup_completed_at = Time.now
  @group.save!
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
