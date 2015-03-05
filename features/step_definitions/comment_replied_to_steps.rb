Given(/^I have posted a comment in the discussion$/) do
  @comment = FactoryGirl.create :comment,
                                 discussion: @discussion,
                                 body: "Parent comment!"
end

When(/^someone replies to my comment$/) do
  @second_user = FactoryGirl.create    :user
  @reply_comment = FactoryGirl.create  :comment,
                                        author: @second_user,
                                        discussion: @discussion,
                                        parent_id: @comment.id
  CommentService.create comment: @reply_comment, actor: @reply_comment.author
end

Then(/^I should receive an email notification$/) do
  @last_email = ActionMailer::Base.deliveries.last
  expect @last_email.to have_subject "#{@second_user.name} replied to your comment in the #{@discussion.group} on Loomio"
end

Then(/^the email should tell me who replied to my comment, and in which discussion$/) do
  expect @last_email.to have_body_text "%{@second_user.name} replied to your comment in the discussion %{discussion.title}"
end
