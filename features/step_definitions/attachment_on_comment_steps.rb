# When(/^I write a comment, select a file to attach and click submit$/) do
#   @comment_text = 'Test comment, with _markdown_'
#   fill_in 'new-comment', with: @comment_text

#   # find("#upload-attachment").click
#   @filename = 'how-loomio-works.png'
#   attach_file('file', File.join(Rails.root, "app/assets/images/#{@filename}"))
#   click_on 'post-new-comment'
# end

When(/^I attach a file$/) do
  @filename = 'how-loomio-works.png'
  find(:xpath, "//input[@id='file-upload-field']").set @filename
  # page.find('#file-upload-field').set File.join(Rails.root, "app/assets/images/#{@filename}")
  # attach_file('file-upload-field', File.join(Rails.root, "app/assets/images/#{@filename}"))
end

When(/^I post a comment$/) do
  step 'I write and submit a comment'
end

Then(/^I should see the posted comment with the attachment$/) do
  page.find('#comment-attachment').should have_content(@filename)
end

When(/^I attach a file and cancel the upload$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see the posted comment without an attachment$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^remove the file$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I attach an oversized file$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be told the file is oversized$/) do
  pending # express the regexp above with the code you wish you had
end
