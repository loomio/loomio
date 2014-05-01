Given(/^the discussion has a proposal$/) do
  @motion = FactoryGirl.create :motion, discussion: @discussion, author: @user
  @group_member = FactoryGirl.create :user
  @group.add_member!(@group_member)
end

Given(/^the proposal has closed$/) do
  @motion.store_users_that_didnt_vote
  @motion.closed_at = Time.now
  @motion.save!
  Events::MotionClosed.publish!(@motion)
  visit discussion_path(@discussion)
end

Given(/^I have recieved an email with subject "(.*?)"$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should include arg1
end

When(/^I click the link to create a proposal outcome$/) do
  open_email(@user.email, :with_subject => "Proposal closed")
  link = links_in_email(current_email)[2]
  request_uri = URI::parse(link).request_uri
  visit request_uri
end

# When(/^I see the proposal outcome field highlighted$/) do
#   page.should have_css "#outcome-input:focus"
# end

When(/^I specify a proposal outcome$/) do
  fill_in 'motion[outcome]', with: "Let's talk to hank about doing that thing."
end

Then(/^my group members should receive an email with subject "(.*?)"$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should include arg1
end

Given(/^a proposal outcome has been created$/) do
  @motion.update_attributes(outcome: "Let's talk to hank about doing that thing.")
end

When(/^I edit the proposal outcome$/) do
  visit discussion_path(@discussion)
  find('#edit-outcome').click
  fill_in 'motion[outcome]', with: "Let's talk to Hank about doing that thing."
  find('#add-outcome-submit').click
end

Then(/^my group members should not receive an email with subject "(.*?)"$/) do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.subject.should_not =~ /arg1/
end

Then(/^they should recieve a notification that an outcome has been created$/) do
  @group_member.notifications.joins(:event).
  where('events.kind = ?', 'motion_outcome_created').
  should exist
end

Then(/^I should see the outcome has been edited in the activity feed$/) do
  page.should have_content(I18n.t('discussion_items.motion_outcome_updated'))
end

Given(/^a proposal outcome has been sent$/) do
  MotionService.close(@motion)
  MotionService.create_outcome(@motion,
                              {outcome: 'This is what we do.'},
                              @user)
end

Given(/^my group is paying a subscription$/) do
  @group.update_attribute(:payment_plan, 'manual_subscription')
end

Given(/^my group is not paying a subscription$/) do
  @group.update_attribute(:payment_plan, 'pwyc')
end

Then(/^I should see the campaign in the email body$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.default_part_body.to_s.should include "Was this decision important to you?"
end

Then(/^I should not see the campaign in the email body$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.default_part_body.to_s.should_not include "Was this decision important to you?"
end
