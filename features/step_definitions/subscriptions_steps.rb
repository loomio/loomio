Given(/^I am a coordinator of a subscription group$/) do
  @group = FactoryGirl.create :group, paying_subscription: true
  @group.add_admin!(@user)
end

Given(/^I have not selected a subscription plan$/) do
  Group.any_instance.stub(has_subscription_plan?: false)
end

Given(/^I have already selected a subscription plan$/) do
  Group.any_instance.stub(has_subscription_plan?: true)
end

When(/^I select Payment details$/) do
  find("#group-options").click
  click_on "Payment details"
end

Then(/^I should see the payment details for my group$/) do
  page.should have_css('body.subscriptions.view_payment_details')
end

Then(/^I should be told that I can email to change my plan$/) do
  page.should have_link("accounts@loomio.org")
end

Given(/^I am a member of a subscription group$/) do
  @group = FactoryGirl.create :group, paying_subscription: true
  @group.add_member!(@user)
end

Then(/^I should not see a link to payment details$/) do
  page.should_not have_content("Payment details")
end

When(/^I visit the payment details page$/) do
  visit group_subscription_path(@group)
end

Given(/^I am a coordinator of a PWYC group$/) do
  @group = FactoryGirl.create :group, paying_subscription: false
  @group.add_admin!(@user)
end
