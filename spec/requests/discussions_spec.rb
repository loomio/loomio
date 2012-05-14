require 'spec_helper'

describe "Discussion" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make
      @group.save
      @group.add_member!(@user)
      page.driver.post user_session_path, 'user[email]' => @user.email,
                       'user[password]' => 'password'
    end

    it "can create a new discussion" do
      visit new_discussion_path(discussion: { group_id: @group.id })

      fill_in 'discussion_title', with: 'This is a new discussion'
      fill_in 'discussion_comment', with: 'Blahhhhhh'
      click_on 'Create discussion'
      should have_css(".discussions.show")
      should have_content('Blahh')
    end

    it "can create a new proposal" do
      discussion = Discussion.new
      discussion.group = @group
      discussion.title = "New discussion!"
      discussion.author = @user
      discussion.save

      visit discussion_path(discussion)

      find('#new-proposal').click
      should have_css(".discussions.new_proposal")
    end

    it "can comment on a discussion" do
      discussion = Discussion.new
      discussion.group = @group
      discussion.title = "New discussion!"
      discussion.author = @user
      discussion.save

      visit discussion_path(discussion)

      fill_in 'new-comment', with: "Here's a little comment"
      click_on 'post-new-comment'
      should have_css(".discussions.show")
      should have_content("Here's a little comment")
    end
  end
end

