Given(/^I am a coordinator of a subscription group$/) do
  @group = FactoryGirl.create :group, paying_subscription: true
  @group.add_admin!(@user)
end

Given(/^I have not selected a subscription plan$/) do
  @group.has_subscription_plan?.should be_false
end

When(/^I select Payment details$/) do
  find("#group-options").click
  click_on "Payment details"
end

Then(/^I should see links to the different plans$/) do
  page.should have_css('.payment-option-container')
end

Given(/^I have already selected a subscription plan$/) do
  @group.has_subscription_plan?.should be_true
end

Then(/^I should see the payment details for my group$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be told that I can email to change my plan$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am a member of a subscription group$/) do
  @group = FactoryGirl.create :group, paying_subscription: true
  @group.add_member!(@user)
end

Then(/^I should not see a link to payment details$/) do
  page.should_not have_content("Payment details")
end

When(/^I visit the payment details page$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am a coordinator of a PWYC group$/) do
  @group = FactoryGirl.create :group, paying_subscription: false
  @group.add_admin!(@user)
end
