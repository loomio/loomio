Given /^I have voted on the proposal$/ do
  @vote = FactoryGirl.create :vote, :user => @user, :motion => @motion, :statement => 'Original vote'
end

When /^I click the 'yes' vote button$/ do
  find('#yes-vote').click
end

When /^I click the 'abstain' vote button$/ do
  find('#abstain-vote').click
end

When /^I click the 'no' vote button$/ do
  find('#no-vote').click
end

When /^I click the 'block' vote button$/ do
  find('#block-vote').click
end

When /^I enter a statement$/ do
  fill_in 'vote_statement', with: "I love this!!"
  find('#submit-vote').click
end

When /^I enter a statement for my block$/ do
  fill_in 'vote_statement', with: "I dont want this to go ahead!"
  find('#submit-vote').click
end

Then /^the proposal author should recieve an email with subject "(.*?)"$/ do |subject|
  last_email = ActionMailer::Base.deliveries.last
  expect(last_email.subject).to match(/Proposal blocked/)
end

Then /^I should see my vote in the list of positions$/ do
  find('.votes-table').should have_content(@user.name)
end

Then /^I should not see the vote buttons$/ do
  page.should_not have_css('#yes-vote')
  page.should_not have_css('#abstain-vote')
  page.should_not have_css('#no-vote')
  page.should_not have_css('#block-vote')
end

When /^I edit my vote$/ do
  click_on('edit-vote')
  step 'I enter a statement'
end

Then /^I should see my new vote in the list of positions$/ do
  find('.votes-table').should have_content('I love this!!')
end

Then /^I should not see my original vote in the list of positions$/ do
  find('.votes-table').should_not have_content('Original vote')
end

Then /^I should see my block in the activity feed$/ do
  find('#activity-list').should have_content('I dont want this to go ahead!')
end

Then /^I should see new vote in the activity feed$/ do
  find('#activity-list').should have_content('I love this!!')
end

When(/^I try to visit the vote page$/) do
  visit new_motion_vote_path(@motion)
end

Then(/^I should be returned to the vote page$/) do
  page.should have_css('body.votes.new')
end

Given(/^I follow a vote link from an email$/) do
  visit new_motion_vote_path(motion_id: @motion.id, position: 'yes', from_email: true)
end

Then(/^I should not see an edit button next to my vote/) do
  page.should_not have_css('#edit-vote')
end

Then(/^I should see my existing vote$/) do
  page.should have_css('body.votes.new')
end
