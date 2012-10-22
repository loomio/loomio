require 'spec_helper'
include ActionView::Helpers::DateHelper

describe "Discussion" do
  let(:user) { create_logged_in_user }
  subject { page }

  context "a logged in user" do
    before do
      @group = build(:group)
      @group.save
      @group.add_member!(user)
    end

    it "can create a new discussion" do
      visit group_path(id: @group.id)
      find('#start-new-discussion').click
      fill_in 'discussion_title', with: 'This is a new discussion'
      fill_in 'discussion_description', with: 'Blahhhhhh'
      click_on 'Start'
      should have_css(".discussions.show")
      should have_content('Blahh')
    end

    context "viewing a discussion" do
      before do
        @discussion = Discussion.new
        @discussion.group = @group
        @discussion.title = "New discussion!"
        @discussion.author = user
        @discussion.description = "Some basic description" 
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

      context "the markdown engine" do
        before :each do
          visit discussion_path(@discussion)
        end
        it "autolinks a link" do
          fill_in 'new-comment', with: "http://loom.io"
          click_on 'post-new-comment'

          should have_link('http://loom.io', {:href => 'http://loom.io', :target => '_blank'})
        end
        it "correctly formats a complex link" do
          fill_in 'new-comment', with: "[stuff] (http://loom.io/someone's gross url#ew \"Someone's Gross Url\")"
          click_on 'post-new-comment'

          should have_link('stuff', {:href => 'http://loom.io/someone\'s%20gross%20url#ew', :target => '_blank'})
        end
        it "does not allow user inputted html" do
          fill_in 'new-comment', with: "<p id='should_not_be_here'>should_be_here</p>"
          click_on 'post-new-comment'

          should_not have_selector('p#should_not_be_here')
          should have_content('should_be_here')
        end
        it "italicizes with _underscore_italic_ and *bold_italic*" do
          fill_in 'new-comment', with: "_underscore_italic_ and *star_italic*"
          click_on 'post-new-comment'

          should have_selector('em', :text => 'underscore_italic')
          should have_selector('em', :text => 'star_italic')
        end
        it "bolds text with __underscore_bold__ and **star_bold**" do
          fill_in 'new-comment', with: "__underscore_bold__ and **star_bold**"
          click_on 'post-new-comment'

          should have_selector('strong', :text => 'underscore_bold')
          should have_selector('strong', :text => 'star_bold')
        end
        it "formats a ruby code block with ```ruby code_block ```" do
          fill_in 'new-comment', with: "```ruby 
          code_block 
          ```
          "
          click_on 'post-new-comment'

          should have_selector('pre > code.ruby', :text => 'code_block')
        end
      end


      it "can close a proposal (if they have permission)" do
        motion = Motion.new
        motion.name = "A new proposal"
        motion.discussion = @discussion
        motion.author = user
        motion.save
        visit discussion_path(@discussion)
        find('#close-voting').click

        find('#previous-proposals').should have_content(motion.name)
      end

      it "can view a closed proposal" do
        motion = Motion.new
        motion.name = "A new proposal"
        motion.discussion = @discussion
        motion.author = user
        motion.save
        motion.close_voting!

        motion2 = Motion.new
        motion2.name = "A new proposal"
        motion2.discussion = @discussion
        motion2.author = user
        motion2.save
        motion2.close_voting!

        visit discussion_path(@discussion)

        find('#previous-proposals').click_on motion2.name

        find(".motion").should have_content(motion2.name)
      end

      it "can see link to delete their own comments" do
        comment = @discussion.add_comment(user, "hello!")
        visit discussion_path(@discussion)

        find("#comment-#{comment.id}").should have_content('Delete')
      end

      it "cannot see link to delete other people's comments" do
        @user2 = create(:user)
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        visit discussion_path(@discussion)

        find("#comment-#{comment.id}").should_not have_content('Delete')
      end

      it "can 'like' a comment" do
        @user2 = create(:user)
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        visit discussion_path(@discussion)
        find("#comment-#{comment.id}").find_link('Like').click

        should have_content("Liked by #{user.name}")
        should_not have_link("Like")
        should have_link("Unlike")
      end

      it "can 'unlike' a comment" do
        @user2 = create(:user)
        @discussion.group.add_member!(@user2)
        comment = @discussion.add_comment(@user2, "hello!")
        @discussion.comments.first.like(user)

        visit discussion_path(@discussion)
        find("#comment-#{comment.id}").find_link('Unlike').click
        should_not have_content("Liked by #{user.name}")
        should have_link("Like")
        should_not have_link("Unlike")
      end

      context "revision history", :js => true do

        before do
          @user2 = create(:user)
          @discussion.group.add_member!(@user2)
          PaperTrail.whodunnit = @user2.name
          @discussion.update_attribute(:description, @discussion.description + " Some additional info.")
          @modal_window_selector = "#description-revision-history"
        end

        it "can change description to a previous version" do
          open_modal

          find("#description-revision-history").find_link('Prev').click
          assert_modal_flushed
          find_button("Go back to this version").click
          should_not have_content(" Some additional info.")
          should have_content(@discussion.description)
        end

        it "refreshes the modal window with appropriate version details" do
          open_modal

          find(@modal_window_selector).find_link('Prev').click
          assert_modal_flushed
          find(@modal_window_selector).find(".user-profile-fields p").should have_content("Edited about #{time_ago_in_words(@discussion.previous_version.updated_at)} ago by #{@discussion.previous_version.originator}")
        end
        
        # LOCAL HELPERS
        def open_modal
          visit discussion_path(@discussion)
          find("#discussion-context").find_link('See revision history').click
         assert_modal_flushed
        end

        def assert_modal_flushed
          page.execute_script("$('#{@modal_window_selector}').empty()")
          wait_until { page.has_css?("#{@modal_window_selector} div") }
        rescue Capybara::TimeoutError
          flunk 'Expected modal to receive html content.'
        end
      end

    end
  end
end

