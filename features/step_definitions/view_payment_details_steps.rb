Given(/^I am a coordinator of a subscription group$/) do
  @group = FactoryGirl.create :group, payment_plan: 'subscription'
  @group.add_admin!(@user)
end

Given(/^I have not selected a subscription plan$/) do
end

Given(/^I have already selected a subscription plan$/) do
  @group.create_subscription(amount: 30)
end

When(/^I select Payment details$/) do
  find("#group-options").click
  click_on "Group subscription"
end

Then(/^I should see the payment details for my group$/) do
  page.should have_css('body.subscriptions.show')
end

Then(/^I should be told that I can email to change my plan$/) do
  page.should have_link("accounts@loomio.org")
end

Given(/^I am a member of a subscription group$/) do
  @group = FactoryGirl.create :group, payment_plan: 'subscription'
  @group.add_member!(@user)
end

Then(/^I should not see a link to payment details$/) do
  page.should_not have_content("Group subscription")
end

When(/^I visit the payment details page$/) do
  visit group_subscription_path(@group)
end

When(/^I visit the new subscription plan page$/) do
  visit new_group_subscription_path(@group)
end

Then(/^I should be redirected to see my existing subscription$/) do
  page.should have_css('body.subscriptions.show')
end

When(/^I visit the show subscription plan page$/) do
  visit group_subscription_path(@group)
end

Then(/^I should be redirected to the new subscription plan page$/) do
  page.should have_css('body.subscriptions.new')
end

Given(/^I am a coordinator of a manual subscription group$/) do
  @group = FactoryGirl.create :group, payment_plan: 'manual_subscription'
  @group.add_admin!(@user)
end
