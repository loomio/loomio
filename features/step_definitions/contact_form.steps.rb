When(/^I visit the contact page$/) do
  visit contact_path
end

When(/^I fill in and submit the contact form$/) do
  fill_in 'contact_message_name', with: "James Jones"
  fill_in 'contact_message_email', with: "james@example.orfg"
  fill_in 'contact_message_message', with: "Message Body"
  click_on "Send message"
end

Then(/^I should be redirected to the home page$/) do
  page.should have_css("body.marketing.index")
end

Then(/^I should be redirected to the sign in page$/) do
  page.should have_css("body.pages.sessions.new")
end

Then(/^I should see a thank you flash message$/) do
  page.should have_content("Thanks! Someone from our team will get back to you shortly!")
end

Then(/^an email should be sent to @incoming\.intercom\.io$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.to.should include "@incoming.intercom.io"
end

Then(/^the message should be saved to the database$/) do
  ContactMessage.where(message: "Message Body").should exist
end

Given(/^I am a current user$/) do
  @current_user = FactoryGirl.create :user, name: "Bob",
                                     email: "bob@log.com"
  login_automatically @current_user
end

Then(/^I should see my name and email pre\-filled$/) do
  expect(find_field('Your name').value).to eq  "Bob"
  expect(find_field('Your email address').value).to eq  "bob@log.com"
end

Then(/^the message should be saved to the database with my user id$/) do
  ContactMessage.where(user_id: @current_user.id).should exist
end

When(/^I submit the contact form without filling in any fields$/) do
  click_on "Send message"
end

Then(/^I should see the contact form with validation errors$/) do
  page.should have_content("can't be blank")
end
