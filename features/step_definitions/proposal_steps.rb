Given(/^there is a proposal that I have created$/) do
  @motion = FactoryGirl.create(:motion, discussion: @discussion, author: @user)
end
