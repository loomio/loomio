When /^I fill in the proposal details and submit the form$/ do
  @proposal_name = Faker::Lorem.sentence
  @proposal_description = Faker::Lorem.paragraph
  fill_in 'motion_name', with: @proposal_name
  fill_in 'motion_description', with: @proposal_description
  click_on I18n.t('motion_form.submit_create')
end

Then /^I should see the create proposal page$/ do
  page.should have_css("body.discussions.new_proposal")
end

Then /^clicking the link in the email should take him to the proposal$/ do
  step 'I click the third link in the email'
  page.should have_content(@proposal_name)
end

Then /^a new proposal should be created$/ do
  Motion.where(:name => @proposal_name).should exist
end

When /^I am on a group page$/ do
  pending "is this needed?"
  group = Group.all.first
  visit "/groups/" + group.id.to_s
end

Then /^I should see the proposal details$/ do
  proposal_description = @proposal_description.length > 20 ? @proposal_description[0..19] : @proposal_description
  find('.motion-title').should have_content(@proposal_name)
  find('.description').should have_content(proposal_description)
end

Then(/^the time zone should match my time zone setting$/) do
  find('#motion_close_at_time_zone option[selected]').value.should == @user.time_zone_city
end

Given(/^"(.*?)" is the author of the proposal$/) do |arg1|
  @motion.update_attribute(:author, User.find_by_email("#{arg1}@example.org"))
  @motion.save
end
