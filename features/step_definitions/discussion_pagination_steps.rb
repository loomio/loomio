Given(/^a discussion has over (\d+) posts$/) do |arg1|
  51.times do
    comment = FactoryGirl.build(:comment, discussion: @discussion)
    CommentService.create(comment: comment, actor: comment.author)
  end
end

When(/^I click the pagination navigation$/) do
  find('.next_page a').click
end

Then(/^I should see more posts$/) do
  page.should have_css(".activity-item-container")
end

Given(/^a discussion has less than (\d+) posts$/) do |arg1|
  FactoryGirl.create(:comment, discussion: @discussion)
end

Then(/^I should not see the pagination navigation$/) do
  page.should_not have_css(".pagination")
end
