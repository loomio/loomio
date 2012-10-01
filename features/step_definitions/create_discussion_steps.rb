When /^I visit the create discussion page$/ do
  click_link 'Start a discussion'
end

When /^fill in discussion details$/ do
  fill_in 'discussion_title', with: 'New discussion Test'
  fill_in 'discussion_description', with: 'Description of test discussion'
  click_on 'discussion-submit'
end

Then /^a discussion should be created$/ do
  Discussion.where(:title => "New discussion Test").should exist
end

Given /^I am viewing a discussion titled "(.*?)" in "(.*?)"$/ do |disc_title, group_name|
  discussion = FactoryGirl.create :discussion,
               :title => disc_title, :group => Group.find_by_name(group_name)
  visit discussion_path(discussion)
end
