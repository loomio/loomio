require 'spec_helper'

describe "Groups" do
  subject { page }

  context "a logged in user" do
    before :all do
      @user = User.make!(email: "test123@test.com", password: "testing123")
      @group = Group.make!(name: 'Test Group')
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group)
      @group2 = Group.make!(name: 'Test Group')
    end
    before :each do
      page.driver.post user_session_path, 'user[email]' => @user.email, 'user[password]' => 'testing123'
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
        should have_content("New Motion")
      end
    end

    it "doesn't let us view a group the user does not belongs to" do
      visit group_path(@group2)
      should have_content("Test Group")
      should have_no_content("Users")
    end
  end
end
