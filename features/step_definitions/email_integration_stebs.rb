Given(/^I have been at mentioned in a discussion$/) do
  @comment = FactoryGirl.create :comment
  @discussion = @comment.discussion
  @user = @comment.group.admins.first
  UserMailer.mentioned(@user, @comment).deliver
end

Given(/^I receive an email with a reply\-to token$/) do
  reply_email = ActionMailer::Base.deliveries.last.reply_to.first
  @token = reply_email.split('@').first.split('+').last
end

When(/^I reply to that email saying "(.*?)"$/) do |arg1|
  @reply_text = arg1
  reply_email_hash = FactoryGirl.create(:reply_email,
       to: "Rich Bartlett <reply+#{@token}@mail.loomio.org>",
       text: @reply_text).
      to_h
  page.driver.post '/email_processor', reply_email_hash
end

Then(/^my reply should become a discussion comment$/) do
  @discussion.comments.last.body.should == @reply_text
end
