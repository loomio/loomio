When(/^I am a member a manual subcription group$/) do
  @subscription_group = FactoryGirl.create(:group, payment_plan: 'manual_subscription')
  @subscription_group.add_member! @user
end

Then(/^I should not see the beta logo$/) do
  visit group_path(@subscription_group)
  page.should_not have_css('.loomio-beta-logo')
end

When(/^I am not a member of a manual subcription group$/) do
  @group = FactoryGirl.create(:group)
  @group.add_member! @user
end

Then(/^I should see the beta logo$/) do
  visit group_path(@group)
  page.should have_css('.loomio-beta-logo')
end
