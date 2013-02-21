require 'spec_helper'

describe "Notifications" do
  subject { page }

  context "a logged in user, member of a group" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user, User.loomio_helper_bot)
      login @user
    end

    # Spec:
    #
    # Given that I am a member of a group
    # And given that someone else has created a new discussion in the group
    # When I visit the dashboard
    # Then I should see a new notification on the notifications icon
    #
    context "new discussion is created" do
      before { create(:discussion, group: @group) }

      it "should have a notification count of 2" do
        visit root_path
        find("#notifications-count").should have_content("2")
      end
    end

    context "two new discussions are created" do
      before do
        create(:discussion, group: @group)
        create(:discussion, group: @group)
      end

      it "should have a notification count of 3" do
        visit root_path
        find("#notifications-count").should have_content("3")
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
        @user = create(:user)
        @group = create(:group, name: 'Test Group', viewable_by: :members)
        @group.add_member!(@user)
        login @user
      end

      it "shows and clears notifications" do
        discussion = create(:discussion, group: @group)
        visit root_path
        page.should have_xpath("//title", :text => "(2) Loomio")

        find("#notifications-count").should have_content("2")

        find("#notifications-toggle").click
        page.should have_xpath("//title", :text => "Loomio")
        page.should have_css("#notifications-count.hidden")

        find("#notifications-container").should have_content("new discussion")
      end

      it "does not break site if notification item no longer exists" do
        discussion = create(:discussion, group: @group)
        discussion.delete
        visit root_path

        page.should have_css("body.dashboard.show")
      end
    end
  end
end
