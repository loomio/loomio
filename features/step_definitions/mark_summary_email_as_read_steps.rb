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

  reader = DiscussionReader.for(user: @user, discussion: @discussion)
  expect(@discussion.salient_items_count - reader.read_salient_items_count).to eq 3
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
  reader = DiscussionReader.for(user: @user, discussion: @discussion)
  expect(@discussion.salient_items_count - reader.read_salient_items_count).to eq 1
end
