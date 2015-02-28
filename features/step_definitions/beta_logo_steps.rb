When(/^I am a member a manual subcription group$/) do
  @subscription_group = FactoryGirl.create(:group, payment_plan: 'manual_subscription')
  @subscription_group.add_member! @user
end

When(/^I am not a member of a manual subcription group$/) do
  @group = FactoryGirl.create(:group)
  @group.add_member! @user
end

Then(/^I should see the beta logo$/) do
  visit group_path(@group)
  expect(page.body).to_not match(/navbar-logo\.png/)
end

Then(/^I should not see the beta logo$/) do
  visit group_path(@subscription_group)
  expect(page.body).to_not match(/navbar-logo-beta\.jpg/)
end

Given(/^my system admin defined us a custom logo$/) do
  ENV['APP_LOGO_PATH'] ='www.image_store.com/custom_logo.png'
end

Then(/^I should see our custom logo instead of any loomio logo$/) do
  visit group_path(@group)
  expect(page.body).to match(/www\.image_store\.com\/custom_logo\.png/)
end

