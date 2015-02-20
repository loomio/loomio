Given(/^there is a new discussion in the group$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)

  @comment = FactoryGirl.build :comment, discussion: @discussion
  CommentService.create(comment: @comment, actor: @comment.author)
end

Given(/^I am subscribed to the missed yesterday email$/) do
  @user.update_attribute(:email_missed_yesterday, true)
end

When(/^the missed yesterday email is sent$/) do
  ActionMailer::Base.deliveries = []
  UserMailer.missed_yesterday(@user).deliver_now
end

Then(/^I should get an email updating me of the content$/) do
  ActionMailer::Base.deliveries.last.to.should include @user.email
end

Then(/^I should not get a missed yesterday email$/) do
  ActionMailer::Base.deliveries.should be_empty
end

