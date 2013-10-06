When(/^I visit the new subscription page for the group$/) do
  visit new_group_subscription_path(@group)
end

When(/^I choose and pay for the plan "(.*?)"$/) do |plan|
  @start_time = 100
  @amount = plan.match('\d+')[0].to_i
  @group.update_attribute(:name, 'Enspiral')
  PaypalCheckout.any_instance.stub(gateway_url:
    confirm_group_subscription_path(@group, amount: @amount, token: "T0K3N"))
  PaypalSubscription.any_instance.stub(start_time: @start_time)
  VCR.use_cassette("paypal success",
                   match_requests_on: [:uri, :body]) do
    choose plan
    click_on "Pay now with Paypal"
  end
end

When(/^I choose and pay for a custom plan$/) do
  @start_time = 100
  @amount = 25
  @group.update_attribute(:name, 'Enspiral')
  PaypalCheckout.any_instance.stub(gateway_url:
    confirm_group_subscription_path(@group, amount: @amount, token: "T0K3N"))
  PaypalSubscription.any_instance.stub(start_time: @start_time)
  VCR.use_cassette("paypal success",
                   match_requests_on: [:uri, :body]) do
    fill_in "subscription_form_custom_amount", with: "25"
    click_on "Pay now with Paypal"
  end
end

Then(/^I should see a page telling me I have subscribed$/) do
  page.should have_content("Thank you!")
end

Then(/^the group's subscription details should be saved$/) do
  @group.reload
  @subscription = @group.subscription
  @subscription.amount.should == @amount
  @subscription.should be_valid
  unless @amount == 0
    @subscription.profile_id.should_not be_blank
  end
end

When(/^I visit the paypal confirmation page and give bad data$/) do
  @group.update_attribute(:name, 'Enspiral')
  PaypalSubscription.any_instance.stub(start_time: @start_time)
  VCR.use_cassette("paypal failure",
                   match_requests_on: [:uri, :body]) do
    visit confirm_group_subscription_path(@group, amount: 25, token: "fake-token")
  end
end

Then(/^the group's subscription details should not be saved$/) do
  @group.reload
  @group.subscription.should be_nil
end

Then(/^I should see a page telling me the payment failed$/) do
  page.should have_content("something went wrong")
end

When(/^view screenshot$/) do
  view_screenshot
end

When(/^I try to pay an invalid custom amount$/) do
  fill_in "subscription_form_custom_amount", with: "$3"
  click_on "Pay now with Paypal"
end

Then(/^I should be told the amount was invalid$/) do
  page.should have_content("Custom amount was invalid. Please enter a number above 0.")
end

When(/^I choose the \$0 per month plan$/) do 
  choose "$0 per month"
  @amount = 0
end

Then(/^I should see the love note pop up$/) do
  page.should have_content "still love you"
end

Then(/^I should see the button text change$/) do
  find("#subscription-submit").value.should eq "Submit"
end
