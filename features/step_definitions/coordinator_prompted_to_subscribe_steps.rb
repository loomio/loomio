Given(/^I am a coordinator of a group$/) do
  step 'I am an admin of a group'
end

Given(/^the group is due for a subscription prompt$/) do
  @group.update_attribute(:created_at, 2.months.ago)
end

Then(/^I should see the subscription prompt$/) do
  page.should have_css("#subscription_prompt")
end

Given(/^the group is not due for a subscription prompt$/) do
  # do nothing: new groups don't see the prompt
end

Then(/^I should not see the subscription prompt$/) do
  page.should_not have_css("#subscription_prompt")
end
