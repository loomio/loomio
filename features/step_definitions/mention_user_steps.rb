Given(/^"(.*?)" has been invited to the group but has not accepted$/) do |recipient_email|
  args = { recipient_email: recipient_email, inviter: @user, invitable: @group }
  InvitationService.create_invite_to_join_group(args)
end

Then(/^I should not see "(.*?)" in the menu that pops up$/) do |recipient_email|
  page.should_not have_content(recipient_email)
end

When /^I am adding a comment and type in "(.*?)"$/ do |arg1|
  fill_in 'new-comment', with: arg1
end

When /^I click on "(.*?)" in the menu that pops up$/ do |arg1|
  # this is failing intermittently (on Poltergeist at least)
  page.should have_content(arg1)
  page.find(:css, "li", :text => arg1).click
end

When /^a comment exists mentioning "(.*?)"$/ do |text|
  @comment = Comment.new(body: "Hey #{text}")
  @comment.author = @user
  @comment.discussion = @discussion
  DiscussionService.add_comment(@comment)
end

When /^I submit a comment mentioning "(.*?)"$/ do |mention|
  fill_in 'new-comment', with: mention
  click_button 'post-new-comment'
end

Then /^I should see "(.*?)" added to the "(.*?)" field$/ do |text, field|
  input = find_field(field)
  input.value.should =~ /#{text}/
end

Then /^I should see a link to "(.*?)"\s user$/ do |user|
  page.should have_link("@#{user}")
end

When /^I write and submit a comment that mentions harry$/ do
  fill_in 'new-comment', with: "hi @harry , do you like *markdown*?"
  click_on 'Post comment'
end

Then /^harry should get an email saying I mentioned him$/ do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.to.should include 'harry@example.org'
  @last_email.default_part_body.should have_content 'mentioned'
  @last_email.default_part_body.should have_content 'change your email preferences'
end

Then /^harry should get an email with markdown rendered saying I mentioned him$/ do
  step 'harry should get an email saying I mentioned him'
  @last_email.default_part_body.should have_content 'markdown'
  @last_email.default_part_body.should_not have_content '*markdown*'
end

Then /^harry should get an email without markdown rendered saying I mentioned him$/ do
  step 'harry should get an email saying I mentioned him'
  @last_email.default_part_body.should have_content '*markdown*'
end

Given /^harry wants to be emailed when mentioned$/ do
  harry = User.find_by_email 'harry@example.org'
  harry.update_attribute(:subscribed_to_mention_notifications, true)
end

Then /^the user should be notified that they were mentioned$/ do
  Event.where(:kind => "user_mentioned").count.should == 1
end

Then /^the user should not be notified that they were mentioned$/ do
  Event.where(:kind => "user_mentioned").count.should == 0
end

Given /^I wait (\d+) seconds?$/ do |sec|
  sleep(sec.to_i)
end
