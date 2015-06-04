When(/^I attempt to create ([0-9]+) comments in the discussion$/) do |int|
  ENV['TESTING_RATE_LIMIT'] = '1'
  int.to_i.times do |i|
    @comment_text = "RambotSpamBot#{i}"
    if first('#new-comment')
      fill_in 'new-comment', with: @comment_text
      click_on 'post-new-comment'
    else
      break
    end
  end
end

Then(/^I should see a rate limiting error page$/) do
  page.should have_selector '#too-many-requests'
  ENV.delete('TESTING_RATE_LIMIT')
end
