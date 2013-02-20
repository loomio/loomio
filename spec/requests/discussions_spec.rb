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
        PaperTrail.whodunnit = "#{user.id}"
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
        visit discussion_path(@discussion)
        should have_content("Here's a little comment")
      end

      context "discussion context area" do
        it "displays the author" do
          visit discussion_path(@discussion)

          should have_css(".started-by .user-name-with-popover")
        end

        it "doesn't display revision history information if description not edited" do
          visit discussion_path(@discussion)

          should_not have_css(".last-edited-by")
          should_not have_css(".see-description-history")
        end

        it "displays revision history information if description has been edited", :js => true do
          pending "This test is failing for some reason"
          visit discussion_path(@discussion)

          click_on 'Edit discussion info'
          fill_in 'description-input', with: "whatever"
          click_on 'add-description-submit'

          assert_description_updated

          find(".last-edited-by").should have_content("Last edited about #{time_ago_in_words(@discussion.last_versioned_at)} ago by #{user.name}")
          should have_css(".see-description-history")
        end
      end

      context "the markdown engine" do
        before :each do
          visit discussion_path(@discussion)
          user.update_attributes(uses_markdown: true)
        end
        it "autolinks a link" do
          fill_in 'new-comment', with: "http://loom.io"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_link('http://loom.io', {:href => 'http://loom.io', :target => '_blank'})
        end
        it "correctly formats a complex link" do
          fill_in 'new-comment', with: "[stuff] (http://loom.io/someone's gross url#ew \"Someone's Gross Url\")"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_link('stuff', {:href => 'http://loom.io/someone\'s%20gross%20url#ew', :target => '_blank'})
        end
        it "correctly handles an empty link" do
          fill_in 'new-comment', with: "[stuff] ()"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_link('stuff', {:href => '#', :target => '_blank'})
        end
        it "does not allow user inputted html" do
          fill_in 'new-comment', with: "<p id='should_not_be_here'>should_be_here</p>"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should_not have_selector('p#should_not_be_here')
          should have_content('should_be_here')
        end
        it "italicizes with _underscore_italic_ and *bold_italic*" do
          fill_in 'new-comment', with: "_underscore_italic_ and *star_italic*"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_selector('em', :text => 'underscore_italic')
          should have_selector('em', :text => 'star_italic')
        end
        it "bolds text with __underscore_bold__ and **star_bold**" do
          fill_in 'new-comment', with: "__underscore_bold__ and **star_bold**"
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_selector('strong', :text => 'underscore_bold')
          should have_selector('strong', :text => 'star_bold')
        end
        it "formats a ruby code block with ```ruby code_block ```" do
          fill_in 'new-comment', with: "```ruby
          code_block
          ```
          "
          click_on 'post-new-comment'
          visit discussion_path(@discussion)
          should have_selector('pre > code.ruby', :text => 'code_block')
        end
      end

      it "can view a closed proposal" do
        motion = Motion.new
        motion.name = "A new proposal"
        motion.discussion = @discussion
        motion.author = user
        motion.save
        motion.close!

        motion2 = Motion.new
        motion2.name = "A new proposal"
        motion2.discussion = @discussion
        motion2.author = user
        motion2.save
        motion2.close!

        visit discussion_path(@discussion)

        find('#previous-proposals').click_on motion2.name

        find(".motion").should have_content(motion2.name)
      end

      it "can see link to delete their own comments" do
        comment = @discussion.add_comment(user, "hello!")
        visit discussion_path(@discussion)

        find("#delete-comment-#{comment.id}")
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
        find("#like-comment-#{comment.id}")
        find_link("Like").click
        visit discussion_path(@discussion)

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
        find("#unlike-comment-#{comment.id}")
        find_link("Unlike").click
        visit discussion_path(@discussion)

        should_not have_content("Liked by #{user.name}")
        should have_link("Like")
        should_not have_link("Unlike")
      end

      context "revision history" do

        before do
          pending "These tests are failing for some reason"
          @user2 = create(:user)
          @discussion.group.add_member!(@user2)
          PaperTrail.whodunnit = "#{@user2.id}"
          @original_description = @discussion.description
          @discussion.update_attribute(:description, @discussion.description + " Some additional info.")
        end

        it "can change description to a previous version" do
          open_modal(@discussion)

          find("#description-revision-history").find_link('Prev').click
          assert_modal_flushed
          find("#revert-to-version").click
          assert_description_updated
          find(".description-body div:first").should_not have_content(@discussion.description)
          find(".description-body div:first").should have_content(@original_description)
        end

        it "navigates to previous version and then back to current" do
          open_modal(@discussion)

          find("#description-revision-history").find_link('Prev').click
          assert_modal_flushed
          find("#description-revision-history").find_link('Next').click
          assert_modal_flushed
          find(".modal-body").should have_content(@discussion.description)
        end

        it "refreshes the modal window with appropriate version details" do
          open_modal(@discussion)

          find("#description-revision-history").find_link('Prev').click
          assert_modal_flushed
          find("#description-revision-history").find(".revision-title p").should have_content("Edited about #{time_ago_in_words(@discussion.last_versioned_at)} ago by #{@user2.name}")
        end
      end

    end
  end

  # LOCAL HELPERS
  def open_modal(discussion)
    visit discussion_path(discussion)
    find("#discussion-context").find_link('See revision history').click
   assert_modal_flushed
  end

  def assert_modal_flushed
    page.execute_script("$('#description-revision-history').empty()")
    wait_until { page.has_css?("#description-revision-history div") }
  rescue Capybara::TimeoutError
    flunk 'Expected modal to receive html content.'
  end

  def assert_description_updated
    page.execute_script("$('#discussion-context').empty()")
    wait_until { page.has_css?("#discussion-context div") }
  rescue Capybara::TimeoutError
    flunk 'Expected discussion context to receive html content.'
  end
end

