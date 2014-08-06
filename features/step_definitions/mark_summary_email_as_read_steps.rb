Given(/^I am a logged out user with an unread discussion$/) do
  @user = FactoryGirl.create(:user)
  @voter = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
  @group.add_member!(@voter)
  @time_start = 1.hour.ago

  @discussion = FactoryGirl.create(:discussion, group: @group, created_at: @time_start)
  @motion = FactoryGirl.create(:motion, discussion: @discussion, created_at: @time_start)

  Vote.create!(motion: @motion, user: @voter, position: 'yes', created_at: @time_start)

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
    time_start: @time_start.utc.to_i,
    time_finish: 30.minutes.ago.utc.to_i,
    unsubscribe_token: @user.unsubscribe_token
  )
end

When(/^I read the summary email with images enabled$/) do
  visit mark_summary_email_as_read_path(
    time_start: @time_start.utc.to_i,
    time_finish: 30.minutes.ago.utc.to_i,
    unsubscribe_token: @user.unsubscribe_token,
    format: 'gif'
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

