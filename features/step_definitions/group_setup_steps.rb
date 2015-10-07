Given(/^I complete the group setup form$/) do
  fill_in 'group_name', with: "Fantastic Spinners"
  click_on 'Next'
  click_on 'Next'
  find('#group_form_submit').click
end

Then(/^I should be on the group page$/) do
  page.should have_css('.groups.show')
end

When(/^I visit the group setup page$/) do
  visit setup_group_path(@group)
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
  expect(current_path).to eq setup_group_path(@group)
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

Then(/^I should have received the Welcome to Loomio email$/) do
  address = @user.email
  subject = "Welcome to Loomio"
  amount = 1
  expect(unread_emails_for(address).select { |m| m.subject =~ Regexp.new(subject) }.size).to eq parse_email_count(amount)
end

Then(/^I should see the subgroup page$/) do
  page.should have_css(".groups.show")
end
