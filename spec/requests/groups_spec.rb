require 'spec_helper'

describe "Groups" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group')
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group, 
                              author: @user, facilitator: @user)
      page.driver.post user_session_path, 'user[email]' => @user.email, 
                                          'user[password]' => 'password'
    end

    it "can view their groups" do
      visit '/groups'
      should have_selector('h3', text:'Your groups')
    end

    context "viewing a group" do
      before :each do
        visit group_path(@group)
      end

      it "can view the group's contents" do
        should have_content("Test Group")
        should have_content("Users")
      end
      it "can click on 'Create a motion'" do
        click_link 'Create a motion'
        should have_content("New motion")
      end
    end

    it "doesn't let us view a group the user does not belongs to" do
      @group2 = Group.make(name: 'Test Group2')
      @group2.save
      @group2.add_member!(User.make!)
      visit group_path(@group2)
      should have_content("Test Group2")
      should have_no_content("Users")
    end
  end
end
