require 'spec_helper'

describe "Motions" do
  subject { page }

  context "a logged in user" do
    before :all do
      @user = User.make!
      @group = Group.make!(name: 'Test Group')
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group, author: @user)
    end

    before :each do
      page.driver.post user_session_path, 'user[email]' => @user.email, 
                       'user[password]' => 'password'
    end

    it "can view a motion belonging to one of the user's groups" do
      visit group_motion_path(group_id: @group.id, id: @motion.id)
      should have_content('Test Motion')
    end

    it "cannot view a motion if they doesn't have priviledges" do
      # Machinist seems to cause problems when we call .make! in here
      # So we have to call .make and then .save
      g = Group.make
      g.save
      u = User.make
      u.save
      m = create_motion(name: 'Test Motion', group: g)
      m.save
      visit group_motion_path(group_id: g.id, id: m.id)
      should have_no_content('Test Motion')
    end
  end
end
