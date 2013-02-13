When /^I am adding a comment and type in "(.*?)"$/ do |arg1|
  fill_in 'new-comment', with: arg1
end

When /^I click on "(.*?)" in the menu that pops up$/ do |arg1|
  # this is failing intermittently (on Poltergeist at least)
  wait_until { find("#at-view", visible: true) }
  within('#at-view') do
    page.should have_content(arg1)
    page.find(:css, "li", :text => arg1).click
  end
end

When /^a comment exists mentioning "(.*?)"$/ do |text|
  @discussion.add_comment @user, "Hey #{text}"
end

When /^I submit a comment mentioning "(.*?)"$/ do |mention|
  fill_in 'new-comment', with: mention
  click_button "post-new-comment"
end

Then /^I should see "(.*?)" added to the "(.*?)" field$/ do |text, field|
  input = find_field(field)
  input.value.should =~ /#{text}/
end

Then /^I should see a link to "(.*?)"\'s user$/ do |user|
  visit(current_path)
  page.should have_link("@#{user}")
end

When /^I write and submit a comment that mentions harry$/ do
  fill_in 'new-comment', with: 'hi @harry'
  click_on 'Post comment'
end

Then /^harry should get an email saying I mentioned him$/ do
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should include 'harry@example.org'
  last_email.body.should have_content 'mentioned'
  last_email.body.should have_content 'Unsubscribe'
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
