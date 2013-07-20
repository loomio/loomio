Given /^the discussion has an open proposal$/ do
  @motion = FactoryGirl.create :motion, :discussion => @discussion
end

When /^I click the 'Close proposal' button$/ do
  find('#close-voting').click
end

When /^I confirm the action$/ do
  find('#confirm-action').click()
end

Then /^the facilitator should recieve an email with subject "(.*?)"$/ do |subject|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should =~ /Proposal closed/
end

Then /^I should see the proposal in the list of previous proposals$/ do
  find('#previous-proposals').should have_content(@motion.name)
end

Then /^I should not see a link to close the proposal$/ do
  page.should_not have_content("Close proposal")
end

Then(/^the proposal close date should match the date the event was created$/) do
  @motion.reload
  floor = Event.last.created_at - 1.minute
  ceiling =  Event.last.created_at + 1.minute
  @motion.closed_at.should > floor && @motion.closed_at.should < ceiling
end
