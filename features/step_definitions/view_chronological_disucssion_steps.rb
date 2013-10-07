Given(/^discussions per page is (\d+)$/) do |arg1|
  Discussion::PER_PAGE = 50
end

Given(/^there are two comments$/) do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @first_comment = @discussion.add_comment @commenter, "old comment", uses_markdown: false
  @second_comment = @discussion.add_comment @commenter, "new comment", uses_markdown: false
  @discussion.reload
end

Then(/^I should see the comments in order of creation$/) do
  page.should have_css(".activity-item-container:last-child > div > #comment-#{@second_comment.id}")
end

Given(/^there is a discussion that I have previously viewed$/) do
  step 'I visit the discussion page'
  step 'there are two comments'
  reader = @discussion.as_read_by(@user)
  reader.viewed!
end

Given(/^I have previously viewed the second page of the discussion$/) do
  reader = @discussion.as_read_by(@user)
  reader.viewed!
end

Given(/^there has been new activity$/) do
  @third_comment = @discussion.add_comment @commenter, "newest comment", uses_markdown: false
end

Given(/^now there is new activity$/) do
  10.times do
    FactoryGirl.create(:comment, discussion: @discussion, user: @commenter)
  end
end

Then(/^I should not see the new activity indicator$/) do
  page.should_not have_css(".dog-ear")
end

Then(/^I should see the new activity indicator$/) do
  page.should have_css(".dog-ear")
end

Given(/^there is a two page discussion$/) do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  60.times do
    FactoryGirl.create(:comment, discussion: @discussion, user: @commenter)
  end
end

Then(/^I should see the second page$/) do
  find(".pagination > ul li:nth-child(3).active")
end

Then(/^I should see the add comment input$/) do
  find("#comment-input")
end

When(/^I don't see the add comment input$/) do
  page.should_not have_css("#comment-input")
end

Then(/^I visit the last page of the discussion$/) do
  find(".pagination .next_page a").click
end
