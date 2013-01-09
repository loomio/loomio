Given /^"(.*?)" is subscribed to proposal closing soon notification emails$/ do |arg1|
  User.find_by_name(arg1).update_attribute('subscribed_to_proposal_closure_notifications', true)
end

When /^we run the rake task to check for closing proposals, (\d+) hours before it closes\.$/ do |arg1|
  now_but_tomorrow_1_hour_window = (1.day.from_now) ... (1.day.from_now + 1.hour)
  Motion.where(:close_date => now_but_tomorrow_1_hour_window).each do |motion|
    Events::MotionClosingSoon.publish!(motion)
  end
end

Then /^"(.*?)" gets a proposal closing soon email$/ do |arg1|
  user = User.find_by_name(arg1)
  open_email(user.email, :with_subject => "Proposal closing soon")
  current_email.default_part_body.to_s.should include("unsubscribe")
end

Given /^the motion "(.*?)" is closing in (\d+) hours$/ do |arg1, arg2|
  motion = Motion.find_by_name(arg1)
  closing_at = 24.hours.from_now + 30.minutes
  motion.update_attribute(:close_date, closing_at)
end

Given /^"(.*?)" agreed with the proposal "(.*?)"$/ do |arg1, arg2|
  user = User.find_by_name(arg1)
  motion = Motion.find_by_name(arg2)
  vote = Vote.new
  vote.motion = motion
  vote.user = user
  vote.position = 'yes'
  vote.save!
end
