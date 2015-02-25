Given(/^I am a logged out user with an unread discussion$/) do
  @user = FactoryGirl.create(:user)
  @voter = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
  @group.add_member!(@voter)
  @time_start = 1.hour.ago

  @discussion = FactoryGirl.build(:discussion, group: @group, created_at: @time_start)
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)

  @motion = FactoryGirl.build(:motion, discussion: @discussion, created_at: @time_start)
  MotionService.create(motion: @motion, actor: @discussion.author)

  @vote = Vote.new(motion: @motion, user: @voter, position: 'yes', created_at: @time_start)
  VoteService.create(vote: @vote, actor: @vote.author)

  @motion.reload
  @discussion.reload

  @comment = FactoryGirl.build(:comment, discussion: @discussion)
  CommentService.create(comment: @comment, actor: @discussion.author)

  Vote.create!(motion: @motion, user: @voter, position: 'no')

  @motion.reload
  @discussion.reload

  expect(DiscussionReader.for(user: @user, discussion: @discussion).unread_comments_count).to eq 2
  expect(MotionReader.for(user: @user, motion: @motion).unread_votes_count).to eq 1
  expect(MotionReader.for(user: @user, motion: @motion).unread_activity_count).to eq 2
end

When(/^I mark the email as read$/) do
  visit email_actions_mark_summary_email_as_read_path(
    time_start: @time_start.utc.to_i,
    time_finish: 30.minutes.ago.utc.to_i,
    unsubscribe_token: @user.unsubscribe_token
  )
end

When(/^I read the summary email with images enabled$/) do
  visit email_actions_mark_summary_email_as_read_path(
    time_start: @time_start.utc.to_i,
    time_finish: 30.minutes.ago.utc.to_i,
    unsubscribe_token: @user.unsubscribe_token,
    format: 'gif'
  )
end

Then(/^the discussion should be marked as read when the email was generated$/) do
  @motion.reload
  @discussion.reload

  expect(DiscussionReader.for(user: @user, discussion: @discussion).
                   unread_comments_count).to eq 1

  expect(MotionReader.for(user: @user, motion: @motion).unread_votes_count).to eq 1
  expect(MotionReader.for(user: @user, motion: @motion).unread_activity_count).to eq 1
end


#Given(/^I am a logged out user with an unread comment in a discussion$/) do
  #@user = FactoryGirl.create(:user)
  #@group = FactoryGirl.create(:group)
  #@group.add_member!(@user)

  #@discussion = FactoryGirl.build(:discussion, group: @group)
  #@event = DiscussionService.start_discussion(@discussion)
#end

#When(/^I read an email with the mark discussion as read gif in it$/) do
  #visit mark_discussion_as_read_url(discussion_id: @discussion.id,
                                    #event_id: @event.id)

  #view_screenshot

#end

#Then(/^the discussion should be marked as read$/) do
  #@discussion_reader = DiscussionReader.for(user: @user, discussion: @discussion)
  #@discussion_reader.unread_comments_count.should == 0
#end

