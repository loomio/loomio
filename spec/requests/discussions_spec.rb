require 'spec_helper'

describe "Discussion" do
  subject { page }

  context "a logged in user" do
    before do
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

    context "viewing a discussion" do
      before do
        @discussion = Discussion.new
        @discussion.group = @group
        @discussion.title = "New discussion!"
        @discussion.author = @user
        @discussion.save
      end

      it "can create a new proposal" do
        visit discussion_path(@discussion)

        find('#new-proposal').click
        should have_css(".discussions.new_proposal")
      end

      it "can comment on a discussion" do
        visit discussion_path(@discussion)

        fill_in 'new-comment', with: "Here's a little comment"
        click_on 'post-new-comment'
        should have_css(".discussions.show")
        should have_content("Here's a little comment")
      end

      it "can close a proposal (if they have permission)" do
        motion = Motion.new
        motion.name = "A new proposal"
        motion.discussion = @discussion
        motion.author = @user
        motion.save
        visit discussion_path(@discussion)
        find('#close-voting').click

        find('#previous-proposals').should have_content(motion.name)
      end

      it "can view a closed proposal" do
        motion = Motion.new
        motion.name = "A new proposal"
        motion.discussion = @discussion
        motion.author = @user
        motion.save
        motion.close_voting!

        motion2 = Motion.new
        motion2.name = "A new proposal"
        motion2.discussion = @discussion
        motion2.author = @user
        motion2.save
        motion2.close_voting!

        visit discussion_path(@discussion)

        find('#previous-proposals').click_on motion2.name

        find(".motion").should have_content(motion2.name)
      end

      it "can see link to delete their own comments" do
        comment = @discussion.add_comment(@user, "hello!")
        visit discussion_path(@discussion)

        find("#comment-#{comment.id}").should have_content('Delete')
      end

      it "cannot see link to delete other people's comments" do
        @user2 = User.make!
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        visit discussion_path(@discussion)

        find("#comment-#{comment.id}").should_not have_content('Delete')
      end

      it "can 'like' a comment" do
        @user2 = User.make!
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        visit discussion_path(@discussion)
        find("#comment-#{comment.id}").find_link('Like').click

        should have_content("Liked by #{@user.name}")
        should_not have_link("Like")
        should have_link("Unlike")
      end

      it "can 'unlike' a comment" do
        @user2 = User.make!
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        @discussion.comments.first.like(@user)

        visit discussion_path(@discussion)
        find("#comment-#{comment.id}").find_link('Unlike').click
        should_not have_content("Liked by #{@user.name}")
        should have_link("Like")
        should_not have_link("Unlike")
      end
    end
  end
end

