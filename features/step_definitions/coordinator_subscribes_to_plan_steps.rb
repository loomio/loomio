When(/^I visit the new subscription page for the group$/) do
  visit new_group_subscription_path(@group)
end

When(/^I choose and pay for the plan "(.*?)"$/) do |plan|
  @start_time = 100
  @amount = plan.match('\d+')[0].to_i
  PaypalSubscription.any_instance.stub(start_time: @start_time)
  PaypalCheckout.any_instance.stub(gateway_url:
    confirm_group_subscription_path(@group, amount: @amount, token: "T0K3N"))
  VCR.use_cassette("paypal success",
                   match_requests_on: [:uri, :body]) do
    click_on plan
  end
end

Then(/^I should see a page telling me I have subscribed$/) do
  page.should have_content("Your subscription payment is now set up")
end

Then(/^the group's subscription details should be saved$/) do
  @group.reload
  @subscription = @group.subscription
  @subscription.amount.should == @amount
  @subscription.should be_valid
  @subscription.profile_id.should_not be_blank
end

When(/^I visit the paypal confirmation page and give bad data$/) do
  PaypalSubscription.any_instance.stub(start_time: @start_time)
  VCR.use_cassette("paypal failure",
                   match_requests_on: [:uri, :body]) do
    visit confirm_group_subscription_path(@group, amount: 30, token: "fake-token")
  end
end

Then(/^the group's subscription details should not be saved$/) do
  @group.reload
  @group.subscription.should be_nil
end

Then(/^I should see a page telling me the payment failed$/) do
  page.should have_content("something went wrong")
end

Then(/^I should see buttons for all the different plans$/) do
  page.should have_link('$30/month', :href => "/groups/#{@group.id}/subscription?amount=30")
  page.should have_link('$50/month', :href => "/groups/#{@group.id}/subscription?amount=50")
  page.should have_link('$100/month', :href => "/groups/#{@group.id}/subscription?amount=100")
  page.should have_link('$200/month', :href => "/groups/#{@group.id}/subscription?amount=200")
end

When(/^view screenshot$/) do
  view_screenshot
end
