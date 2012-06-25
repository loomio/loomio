require 'spec_helper'

describe Event do
  it { should belong_to(:discussion) }
  it { should allow_value("new_discussion").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }

  describe "new_discussion!" do
    let(:discussion) { create_discussion }
    let(:event) { Event.new_discussion!(discussion) }
    subject { event }

    specify { subject.kind.should == "new_discussion" }
    specify { subject.discussion.should == discussion }

    it "creates notification for every group member except discussion author" do
      group = discussion.group
      group.add_member! User.make!
      group.add_member! User.make!
      group_size = group.users.size
      Notification.where("event_id = ?", event).size.should == group_size - 1
    end
  end
end
