Given(/^I am a logged out user with an unread discussion$/) do
  @user = FactoryGirl.create(:user)
  @voter = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
  @group.add_member!(@voter)

  @discussion = FactoryGirl.create(:discussion, group: @group, created_at: 1.hour.ago)
  @motion = FactoryGirl.create(:motion, discussion: @discussion, created_at: 1.hour.ago)

  Vote.create!(motion: @motion, user: @voter, position: 'yes', created_at: 1.hour.ago)

  @motion.reload
  @discussion.reload

  @comment = FactoryGirl.create(:comment, discussion: @discussion)
  Vote.create!(motion: @motion, user: @voter, position: 'no')

  @motion.reload
  @discussion.reload

  DiscussionReader.for(user: @user, discussion: @discussion).unread_comments_count.should == 2
  MotionReader.for(user: @user, motion: @motion).unread_votes_count.should == 1
  MotionReader.for(user: @user, motion: @motion).unread_activity_count.should == 2
end

When(/^I mark the email as read$/) do
  visit mark_summary_email_as_read_path(
    email_timestamp: 30.minutes.ago.utc.to_i,
    unsubscribe_token: @user.unsubscribe_token
  )
end

Then(/^the discussion should be marked as read when the email was generated$/) do
  @motion.reload
  @discussion.reload

  DiscussionReader.for(user: @user, discussion: @discussion).
                   unread_comments_count.should == 1

  MotionReader.for(user: @user, motion: @motion).unread_votes_count.should == 1
  MotionReader.for(user: @user, motion: @motion).unread_activity_count.should == 1
end

