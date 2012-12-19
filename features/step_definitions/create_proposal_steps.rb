When /^fill in the proposal details and submit the form$/ do
  @proposal_name = Faker::Lorem.sentence
  @proposal_description = Faker::Lorem.paragraph
  fill_in 'motion_name', with: @proposal_name
  fill_in 'motion_description', with: @proposal_description
  click_on 'proposal-submit'
end

Then /^"(.*?)" should be emailed about the new proposal$/ do |arg1|
  open_email(@notified_user.email, :with_subject => "New proposal")
  current_email.default_part_body.to_s.should include(@proposal_name && "unsubscribe")
end

Then /^clicking the link in the email should take him to the proposal$/ do
  click_first_link_in_email
  page.should have_content(@proposal_name)
end

Then /^"(.*?)" should not be emailed about the new proposal$/ do |arg1|
  mailbox_for(@unnotified_user).size.should == 0
end

Then /^a new proposal is created$/ do
  Motion.where(:name => @proposal_name).should exist
end

When /^I am on a group page$/ do
  pending "is this needed?"
  group = Group.all.first
  visit "/groups/" + group.id.to_s
end

Then /^the email should tell him when the proposal closes$/ do
  pending "this is a reminder to add motion closing time to new_motion_created.html.haml"
end

Then /^I should see the proposal details$/ do
  proposal_description = @proposal_description.length > 20 ? @proposal_description[0..19] : @proposal_description
  find('.motion-title').should have_content(@proposal_name)
  find('.description').should have_content(proposal_description)
  find('.pie').text.blank?.should == false
end