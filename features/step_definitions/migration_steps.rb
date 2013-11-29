Given(/^there is a motion with an outcome but no author$/) do
  @motion = FactoryGirl.create(:motion)
  @outcome_author = FactoryGirl.create(:user)

  @motion.outcome = 'we go to the moon'
  @motion.save!

  Event.create!(:kind => "motion_outcome_created", :eventable => @motion,
            :discussion_id => @motion.discussion.id, :user => @outcome_author)
end

When(/^I run the set_motion_outcome_author migration$/) do
  require 'extras/migrations/20131129_set_outcome_author_for_motions'
  SetOutcomeAuthorForMotionsMigration.now
end

Then(/^that motion now has a motion author$/) do
  @motion.reload
  @motion.outcome_author.should == @outcome_author
end
