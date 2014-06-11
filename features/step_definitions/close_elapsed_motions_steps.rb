Given(/^there is an unclosed motion with closing_at in the past$/) do
  @motion = FactoryGirl.create :motion, closing_at: Date.yesterday
  @motion.closed?.should be_false
  @motion.voting?.should be_true
end

When(/^I close lapsed motions$/) do
  MotionService.close_all_lapsed_motions
end

Then(/^the motion should be closed$/) do
  @motion.reload
  @motion.closed?.should be_true
end
