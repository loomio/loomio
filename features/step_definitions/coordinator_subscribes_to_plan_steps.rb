When(/^I visit the new subscription page for the group$/) do
  visit new_group_subscription_path(@group)
end

When(/^I choose and pay for the plan "(.*?)" successfully$/) do |plan|
  @amount = plan.match('\d+').to_s
  @return_token = "EC-2XE27522GG148073B" # TODO: REPLACE THIS TOKEN WITH NEW ONE
  PaypalCheckout.any_instance.stub(gateway_url:
    confirm_group_subscriptions_path(@group, amount: @amount, token: @return_token))
  VCR.use_cassette("paypal #{@amount}",
                   match_requests_on: [:uri, :body],
                   erb: {token: @return_token},
                   record: :new_episodes) do
    click_on plan
  end
end

Then(/^I should see a page telling me I have successfully subscribed$/) do
  page.should have_content("Well done")
end

Then(/^the system should store my subscription$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I choose and pay for the plan "(.*?)" unsuccessfully$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see a page telling me I have unsuccessfully subscribed$/) do
  pending # express the regexp above with the code you wish you had
end
