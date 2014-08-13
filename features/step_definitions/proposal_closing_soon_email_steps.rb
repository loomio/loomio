Given /^"(.*?)" is subscribed to proposal closing soon emails$/ do |arg1|
  User.find_by_name(arg1).update_attribute(:email_when_proposal_closing_soon, true)
end

When /^we run the rake task to check for closing proposals, (\d+) hours before it closes\.$/ do |arg1|
  Delayed::Job.enqueue ProposalsClosingSoonJob.new
end

Then /^"(.*?)" gets a proposal closing soon email$/ do |arg1|
  user = User.find_by_name(arg1)
  subject ="#{I18n.t(:"email.proposal_closing_soon.closing_in_24_hours")}: #{@motion.name} - #{@group.name}"
  @email = open_email(user.email, :with_subject => subject)
  @email.default_part_body.to_s.should include("unsubscribe")
end

Given /^the proposal "(.*?)" is closing in (\d+) hours$/ do |arg1, arg2|
  @motion = Motion.find_by_name(arg1)
  closing_at = Time.zone.now.at_beginning_of_hour + 24.hours + 30.minutes
  @motion.update_attribute(:closing_at, closing_at)
end

Given /^there is a user called "(.*?)" in timezone "(.*?)"$/ do |arg1, arg2|
  @user_email = "#{arg1}@example.org"
  @user = FactoryGirl.create :user, name: arg1,
                            email: @user_email,
                            password: 'password',
                            time_zone: arg2
end

Then(/^the email should give him the closing time appropriate for his timezone$/) do
  local_time = @motion.closing_at.in_time_zone(TimeZoneToCity.convert @user.time_zone).
               strftime('%A %-d %b - %l:%M%P')

  @email.default_part_body.to_s.should include(local_time)
end
