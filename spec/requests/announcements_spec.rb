require 'spec_helper'

describe "Announcements" do

  context "a logged in user" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      login @user
    end

    it "displays active announcements" do
      Announcement.create! message: "Hello world", starts_at: 1.hour.ago, ends_at: 1.hour.from_now
      Announcement.create! message: "Upcoming", starts_at: 10.minutes.from_now, ends_at: 1.hour.from_now
      visit group_path(@group)
      page.should have_content("Hello world")
      page.should_not have_content("Upcoming")
      click_on 'Click here to dismiss this message'
      page.should_not have_content("Hello world")
    end

    it "stays on page when hiding announcement", js: true do
      Announcement.create! message: "Hello world", starts_at: 1.hour.ago, ends_at: 1.hour.from_now
      visit group_path(@group)
      page.should have_content("Hello world")
      expect { click_on 'Click here to dismiss this message' }.to_not change { page.response_headers }
      page.should_not have_content("Hello world")
    end
  end
end
