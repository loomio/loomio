Given(/^there is an unclosed motion with closing_at in the past$/) do
  @motion = FactoryGirl.create :motion
  @motion.update_attribute(:closing_at, 1.day.ago)

  @motion.closed?.should be false
  @motion.voting?.should be true
end

When(/^I close lapsed motions$/) do
  MotionService.close_all_lapsed_motions
end

Then(/^the motion should be closed$/) do
  @motion.reload
  @motion.closed?.should be true
end
