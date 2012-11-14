Given /^"(.*?)" is subscribed to proposal closing soon notification emails$/ do |arg1|
  User.find_by_name('Ben').update_attribute('subscribed_to_proposal_closure_notifications', true)
end

When /^we run the rake task to check for closing proposals, (\d+) hours before it closes\.$/ do |arg1|
  now_but_tomorrow_1_hour_window = (1.day.from_now) ... (1.day.from_now + 1.hour)
  ActionMailer::Base.deliveries = []
  Motion.where(:close_date => now_but_tomorrow_1_hour_window).each do |motion|
    Event.motion_closing_soon!(motion)
  end
end

Then /^"(.*?)" gets a proposal closing soon email$/ do |arg1|
  user = User.find_by_name(arg1)
  user_emailed = ActionMailer::Base.deliveries.any? do |email|
    email.to.include? user.email
  end
  user_emailed.should be_true
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
