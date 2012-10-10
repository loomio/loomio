# Given /^I visit a public group that I do not belong to$/ do
#   @group = FactoryGirl.create :group
#   @discussion = FactoryGirl.create :discussion, :group => @group
#   visit group_path(@group)
# end

# Then /^I should be able to see that group's discussions$/ do
#   page.should have_css("#discussion-preview-#{@discussion.id}")
# end
