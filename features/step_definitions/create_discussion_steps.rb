When /^I visit the create discussion page$/ do
  click_link 'Start new discussion'
end

When /^fill in discussion details$/ do
  fill_in 'discussion_title', with: 'New discussion Test'
  fill_in 'discussion_comment', with: 'Description of test discussion'
  click_on 'Create discussion'
end

Then /^a discussion is created$/ do
  Discussion.where(:title => 'New Discussion Test').size > 0
end