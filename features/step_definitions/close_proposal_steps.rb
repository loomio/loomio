
Given /^the discussion has an open proposal$/ do
  @motion = FactoryGirl.create :motion, :discussion => @discussion
  @group_member = FactoryGirl.create :user
  @group.add_member!(@group_member)
end

When /^I click the 'Close proposal' button$/ do
  find('#close-voting').click
end

When /^I confirm the action$/ do
  ActionMailer::Base.deliveries = []
  find('#confirm-action').click()
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

Then(/^my group members should recieve a notification that the proposal has been closed$/) do
  @group_member.notifications.joins(:event).
  where('events.kind = ?', 'motion_closed_by_user').
  should exist
end
