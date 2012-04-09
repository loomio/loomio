require 'spec_helper'

describe "Motions" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      @user2 = User.make!
      @group = Group.make(name: 'Test Group')
      @group.save
      @group.add_member!(@user)
      @group.add_member!(@user2)
      @motion = create_motion(name: 'Test Motion', group: @group,
                              author: @user, facilitator: @user)
      @motion.save!
      page.driver.post user_session_path, 'user[email]' => @user.email,
                       'user[password]' => 'password'
    end

    context "viewing a motion in one of their groups" do
      before :each do
        visit motion_path(id: @motion.id)
      end

      it "can see motion contents" do
        should have_content('Test Motion')
      end

      it "can see motion discussion" do
        should have_content('Discussion')
        should have_css('textarea#new-comment')
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
      click_on 'Create motion'
    end
  end
end
