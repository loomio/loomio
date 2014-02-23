Given(/^discussions per page is (\d+)$/) do |arg1|
  Discussion.send(:remove_const, 'PER_PAGE')
  Discussion::PER_PAGE = arg1.to_i
end

Given(/^there are two comments$/) do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @first_comment = Comment.new(body: 'old comment')
  @first_comment.author = @commenter
  @first_comment.discussion = @discussion
  @second_comment = Comment.new(body: 'new comment')
  @second_comment.author = @commenter
  @second_comment.discussion = @discussion
  DiscussionService.add_comment @first_comment
  DiscussionService.add_comment @second_comment

  @discussion.reload
end

Then(/^I should see the comments in order of creation$/) do
  page.should have_css(".activity-item-container:last-child > div > #comment-#{@second_comment.id}")
end

Given(/^there is a discussion that I have previously viewed$/) do
  step 'I visit the discussion page'
  step 'there are two comments'
  DiscussionReader.for(user: @user, discussion: @discussion).viewed!
end


Given(/^there has been new activity$/) do
  @third_comment = @discussion.add_comment @commenter, "newest comment", uses_markdown: false
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
    comment = Comment.new(body: 'yo wassup')
    comment.author = @commenter
    comment.discussion = @discussion
    DiscussionService.add_comment(comment)
  end
end

Given(/^I have previously viewed the second page of the discussion$/) do
  @discussion.reload
  DiscussionReader.for(user: @user, discussion: @discussion).viewed!
end

Given(/^now there is new activity$/) do
  10.times do
    comment = FactoryGirl.build(:comment, discussion: @discussion, user: @commenter)
    DiscussionService.add_comment(comment)
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
