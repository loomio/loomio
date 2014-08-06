require 'rails_helper'

describe Events::MotionClosedByUser do
  let(:discussion) { mock_model(Discussion) }
  let(:motion) { mock_model(Motion, discussion: discussion) }
  let(:closer) { mock_model(User, email: 'bill@dave.com') }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'motion_closed_by_user',
                                          eventable: motion,
                                          user: closer,
                                          discussion_id: motion.discussion.id)
      Events::MotionClosedByUser.publish!(motion, closer)
    end

    it 'returns an event' do
      Events::MotionClosedByUser.publish!(motion, closer).should == event
    end
  end
end
