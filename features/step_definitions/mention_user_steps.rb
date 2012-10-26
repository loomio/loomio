When /^I am adding a comment and type in "(.*?)"$/ do |arg1|
  fill_in 'new-comment', with: +arg1
end

When /^I click on "(.*?)" in the menu that pops up$/ do |arg1|
  within('#at-view') do
    page.should have_content(arg1)
    page.find(:css, "li", :text => arg1).click
  end  
end

Then /^I should see "(.*?)" added to the "(.*?)" field$/ do |text, field|
  input = find_field(field)
  input.value.should =~ /#{text}/
end

When /^a comment exists mentioning "(.*?)"$/ do |text|
  @discussion.add_comment @user, "Hey #{text}"
end

Then /^I should see a link to "(.*?)"'s user$/ do |user|
  page.should have_link("@#{user}")
end 
