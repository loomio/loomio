require 'spec_helper'

describe "Motions" do
  subject { page }

  context "a logged in user" do
    before :each do
      pending "delete this once we've migrated to discussion-centric"
      @user = User.make!
      @user2 = User.make!
      @group = Group.make(name: 'Test Group')
      @group.save
      @group.add_member!(@user)
      @group.add_member!(@user2)
      @discussion = create_discussion(group: @group)
      @motion = create_motion(name: 'Test Motion', discussion: @discussion,
                              author: @user, facilitator: @user)
      @motion.save!
      page.driver.post user_session_path, 'user[email]' => @user.email,
                       'user[password]' => 'password'
    end

    context "closes motion" do
      before :each do
        vote = Vote.create(user: @user, motion: @motion, position: "yes")
        visit motion_path(id: @motion.id)
        click_on "Close Voting"
      end

      it "should be closed" do
        should have_link("Reopen Voting")
      end

      it "should display users that have not voted" do
        find("#still-to-vote").should have_content(@user2.name)
      end

      it "should not display new users since motion closed" do
        @user3 = User.make
        @user3.save
        @group.add_member!(@user3)
        visit motion_path(id: @motion.id)
        find("#still-to-vote").should_not have_content(@user3.name)
      end
    end

    context "viewing a motion in one of their groups" do
      it "can see motion discussion" do
        visit motion_path(id: @motion.id)

        should have_css('#discussion-panel')
      end

      it "can see 'add comment' form on motions" do
        visit motion_path(id: @motion.id)

        should have_css('#new-comment')
      end

      it "can see link to delete their own comments" do
        @motion.discussion.add_comment(@user, "hello!")

        visit motion_path(id: @motion.id)
        find('.comment').should have_content('Delete')
      end

      it "cannot see link to delete other people's comments" do
        @motion.discussion.add_comment(@user2, "hello!")

        visit motion_path(id: @motion.id)
        find('.comment').should_not have_content('Delete')
      end

      it "can 'like' a comment" do
        @motion.discussion.add_comment(@user2, "hello!")

        visit motion_path(id: @motion.id)
        find('.comment').find_link('Like').click
        # TODO: should say "Liked by user2 and you."
        should have_content("Liked by #{@user.name}")
        should_not have_link("Like")
        should have_link("Unlike")
      end

      it "can 'unlike' a comment" do
        @motion.discussion.add_comment(@user2, "hello!")
        @motion.discussion.comments.first.like(@user)

        visit motion_path(id: @motion.id)
        find('.comment').find_link('Unlike').click
        should_not have_content("Liked by #{@user.name}")
        should have_link("Like")
        should_not have_link("Unlike")
      end
    end

    context "viewing a public motion (of a group they don't belong to)" do
      before :each do
        membership = @group.memberships.find_by_user_id(@user.id)
        membership.destroy
        @motion.discussion.add_comment(@user2, "hello!")
        visit motion_path(id: @motion.id)
      end

      it "can see motion discussion" do
        should have_css('#discussion-panel')
      end

      it "cannot see 'add comment' form on motions" do
        should_not have_css('#new-comment')
      end

      it "cannot see 'like/unlike' options on comment " do
        find('.comment').should_not have_link('Like')
        find('.comment').should_not have_link('Unlike')
      end
    end

    it "cannot view a motion if they don't belong to its (private) group" do
      # Machinist seems to cause problems when we call .make! in here
      # So we have to call .make and then .save
      g = Group.make(viewable_by: :members)
      g.save
      u = User.make
      u.save
      m = create_motion(name: 'Test Motion', group: g)
      m.save
      visit group_motion_path(group_id: g.id, id: m.id)
      should have_no_content('Test Motion')
    end

    it "can create a motion" do
      visit new_motion_path(group_id: @group.id)
      fill_in 'motion_name', with: 'This is a new motion'
      fill_in 'motion_description', with: 'Blahhhhhh'
      click_on 'Create Motion'
    end

    it "can disable motion discussion" do
      visit new_motion_path(group_id: @group.id)
      fill_in 'motion_name', with: 'This is a new motion'
      fill_in 'motion_description', with: 'Blahhhhhh'
      uncheck 'motion_enable_discussion'
      click_on 'Create Motion'
      should have_content("Comments have been disabled for this motion")
    end
  end
  context "a logged out user" do
    it "can view a motion of a public group" do
      pending "delete this once we've migrated to discussion-centric"
      @group = Group.make(name: 'Test Group')
      @group.save
      @user = User.make!
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group,
                              author: @user, facilitator: @user)
      @motion.save!
      @motion.discussion.add_comment(@user, "hello!")

      visit motion_path(@motion)

      should have_css('.motions.show')
    end
  end
end
