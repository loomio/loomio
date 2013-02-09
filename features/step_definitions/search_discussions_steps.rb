When /^I enter "(.*?)" in the discussions search input$/ do |search_term|
  fill_in "discussions-search-filter-input", :with => 'search_term'
end

Then /^I should only see discussions with "(.*?)" in the title$/ do |search_term|
  page.all(".discussion-title").each do |title|
    title.text =~ /#{search_term}/
  end
end