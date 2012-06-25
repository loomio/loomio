require 'spec_helper'

describe Notification do
  it { should belong_to(:event) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:event) }
  it { should validate_presence_of(:user) }

  describe "new_discussion!" do
    let(:discussion) { create_discussion }
    let(:user) { User.make! }
    let(:event) { Event.new_discussion!(discussion) }
    let(:notification) { event.notifications.create!(:user => user) }
    subject { notification }

    specify { subject.event.should == event }
    specify { subject.discussion.should == discussion }
  end
end
