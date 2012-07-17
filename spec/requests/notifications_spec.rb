require 'spec_helper'

describe "Notifications" do
  subject { page }

  context "a logged in user, member of a group" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      page.driver.post user_session_path, 'user[email]' => @user.email,
                                          'user[password]' => 'password'
    end

    # Spec:
    #
    # Given that I am a member of a group
    # And given that someone else has created a new discussion in the group
    # When I visit the dashboard
    # Then I should see a new notification on the notifications icon
    #
    context "new discussion is created" do
      before { Event.new_discussion! create_discussion(group: @group) }

      it "should have a notification count of 1" do
        visit root_url
        find("#notifications-count").should have_content("1")
      end
    end

    context "two new discussions are created" do
      before do
        Event.new_discussion! create_discussion(group: @group)
        Event.new_discussion! create_discussion(group: @group)
      end

      it "should have a notification count of 2" do
        visit root_url
        find("#notifications-count").should have_content("2")
      end
    end
  end

  # Spec (TODO):
  #
  # Given that I am a member of a group
  # And given that someone else has created a new discussion in the group
  # When I click on the notification icon
  # Then I should see a notification that a new discussion has been created in the group
  # And I should see my notification count should drop to zero
  #
  context "a logged in user, member of a group" do
    before :each do
    end

    describe "clicking on notifications dropdown" do
      before do
        @user = User.make!
        @group = Group.make!(name: 'Test Group', viewable_by: :members)
        @group.add_member!(@user)

        visit("/users/sign_in")

        fill_in("user_email", :with => @user.email)
        fill_in("user_password", :with => @user.password)
      end

      it "shows and clears notifications", :js => true do
        Event.new_discussion! create_discussion(group: @group)

        click_button("sign-in-btn")

        find("#notifications-toggle").click
        find("#notifications-container").should have_content("new discussion")
      end
    end
  end
end
