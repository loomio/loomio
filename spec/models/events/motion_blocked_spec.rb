require 'spec_helper'

describe Events::MotionBlocked do
  let(:vote) { mock_model(Vote) }

  describe "::publish!" do
    let(:event) { stub(:event, :notify_users! => true) }
    let(:discussion) { mock_model(Discussion) }

    before do
      Event.stub(:create!).and_return(event)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    it 'creates an event' do
      Event.should_receive(:create!)
      Events::MotionBlocked.publish!(vote)
    end

    it 'returns an event' do
      Events::MotionBlocked.publish!(vote).should == event
    end
  end

  context "after event has been published" do
    let(:user) { stub(:user) }
    let(:event) { Events::MotionBlocked.new(kind: "new_comment",
                                                  eventable: vote) }
    before { vote.stub(:other_group_members).and_return([user]) }

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
      event.save
    end
  end
end