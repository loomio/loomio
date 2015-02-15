Given /^I am on the discussion page$/ do
  visit discussion_path(@discussion)
end

When /^I visit the discussion page$/ do
  visit discussion_path(@discussion)
end

When(/^I visit the discussion subscribe to feed link$/) do
  visit discussion_path(@discussion, format: :xml)
end

Then /^I should see the discussion$/ do
  find('#activity-list')
end

Then /^I should not see discussion options dropdown$/ do
  page.should_not have_css('#options-dropdown')
end

Then /^I should see a discussion xml feed$/ do                                                                                                                            
  response = Hash.from_xml page.body
  expect(response['feed']['title']).to eq  @discussion.title
  expect(response['feed']['subtitle']).to eq  @discussion.description
end

Then /^the xml feed should have the comment$/ do 
  response = Hash.from_xml page.body
  response['feed']['entry']['title'].should match /#{@comment.author.name}/
  response['feed']['entry']['author']['uri'].should match /#{@comment.author.key}/
  expect(response['feed']['entry']['content']).to eq  @comment.body
end
