require 'spec_helper'

describe Announcement do
  let(:user) { create(:user) }

  it "has current scope" do
    passed = Announcement.create! message: "Hi", starts_at: 1.day.ago, ends_at: 1.hour.ago
    current = Announcement.create! message: "Hi", starts_at: 1.hour.ago, ends_at: 1.day.from_now
    upcoming = Announcement.create! message: "Hi", starts_at: 1.hour.from_now, ends_at: 1.day.from_now
    Announcement.current(user).should eq([current])
  end
end
