require 'spec_helper'

describe Events::MotionBlocked do
  let(:vote) { mock_model(Vote) }

  describe "::publish!" do
    let(:event) { double(:event, :notify_users! => true) }
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
    let(:user) { create(:user) }
    let(:event) { Events::MotionBlocked.new(kind: "new_comment", eventable: vote) }

    before do
      vote.stub(:other_group_members).and_return([user])
      vote.stub(:position).and_return('yes')
      vote.stub(:previous_position).and_return('yes')
      MotionMailer.stub(:motion_blocked).and_return(double(:mailer, deliver: true))
    end

    after { event.save }

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
    end

    context 'if the vote was a block' do
      it 'fires a motion blocked email' do
        vote.should_receive(:position).and_return('block')
        MotionMailer.should_receive(:motion_blocked).with(vote)
      end

      context 'user\'s previous vote was block' do
        it 'does not fire a motion blocked email' do
          vote.should_receive(:position).and_return('block')
          vote.should_receive(:previous_position).and_return('block')
          MotionMailer.should_not_receive(:motion_blocked).with(vote)
        end
      end
    end
  end
end
