require 'spec_helper'

describe Events::MotionClosed do
  let(:discussion) { mock_model(Discussion) }
  let(:motion) { mock_model(Motion, discussion: discussion) }
  let(:closer) { mock_model(User, email: 'bill@dave.com') }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'motion_closed',
                                          eventable: motion,
                                          discussion_id: motion.discussion.id)
      Events::MotionClosed.publish!(motion)
    end

    it 'returns an event' do
      Events::MotionClosed.publish!(motion).should == event
    end
  end

  context "after event has been published" do
    let(:user) { mock_model(User) }
    let(:event) { Events::MotionClosed.new(kind: "motion_closed",
                                           eventable: motion,
                                           discussion_id: motion.discussion.id) }

    before do
      motion.stub(:author).and_return(closer)
      motion.stub(:group_members).and_return([user])
      MotionMailer.stub_chain(:motion_closed, :deliver)
    end

    it 'emails group_members motion_closed' do
      MotionMailer.should_receive(:motion_closed).with(motion, closer.email)
      event.save
    end

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
      event.save
    end

  end
end
