require 'spec_helper'

describe Event do
  it { should belong_to(:discussion) }
  it { should allow_value("new_discussion").for(:kind) }
  it { should allow_value("new_comment").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }

  let(:discussion) { create_discussion }
  let(:group) { discussion.group }

  describe "new_discussion!" do
    subject { Event.new_discussion!(discussion) }

    its(:kind) { should eq("new_discussion") }
    its(:discussion) { should eq(discussion) }

    it "creates notification for every group member except discussion author" do
      group = discussion.group
      group.add_member! User.make!
      group.add_member! User.make!
      group_size = group.users.size
      event = Event.new_discussion!(discussion)
      Notification.where("event_id = ?", event).size.should eq(group_size - 1)
    end
  end

  describe "new_comment!" do
    let(:comment) { stub_model(Comment, :discussion => discussion) }
    subject { Event.new_comment!(comment) }

    its(:kind) { should eq("new_comment") }
    its(:comment) { should eq(comment) }

    it "notifies discussion participants (people who've already commented in the discussion)" do
      user2, user3, user4 = User.make!, User.make!, User.make!
      group.add_member! user2
      group.add_member! user3
      group.add_member! user4
      comment1 = discussion.add_comment(user2, "hello user3!")
      comment2 = discussion.add_comment(user3, "hi there user2!")
      comment3 = discussion.add_comment(user2, "fancy pantsy")
      event = Event.new_comment!(comment3)
      # Notifications should only be created for discussion.author, user2, and user3
      # NOTE: this test is a bit brittle, should test WHO the notifications were
      # created for. I couldn't think of a concise way to test this though.
      Notification.where("event_id = ?", event).size.should eq(3)
    end
  end
end
