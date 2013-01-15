When /^I enter "(.*?)" in the discussions search input$/ do |search_term|
  fill_in "discussions-search-filter-input", :with => 'search_term'
end

Then /^I should only see discussions with "(.*?)" in the title$/ do |search_term|
  within(".discussion-title") do 
    page.should have_content(@discussion.title) if @discussion.title =~ search_term
    page.should_not have_content(@discussion.title) unless @discussion.title =~ search_term
  end
end