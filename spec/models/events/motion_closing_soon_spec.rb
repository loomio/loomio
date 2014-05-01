require 'spec_helper'

describe Events::MotionClosingSoon do
  let(:motion) { mock_model(Motion, discussion: mock_model(Discussion)) }

  describe "::publish!" do
    let(:event){ double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'motion_closing_soon',
                                          eventable: motion)
      Events::MotionClosingSoon.publish!(motion)
    end

    it 'returns an event' do
      Events::MotionClosingSoon.publish!(motion).should == event
    end
  end

  context "after event has been published" do
    let(:user) { mock_model(User) }
    let(:event) { Events::MotionClosingSoon.new(kind: "motion_closing_soon",
                                        eventable: motion,
                                        discussion_id: motion.discussion.id) }
    before do
      motion.stub(:group_members).and_return([user])
      UserMailer.stub_chain(:motion_closing_soon, :deliver)
      user.stub(:subscribed_to_proposal_closure_notifications)
    end

    context "user is subscribed to proposal closure notifications" do
      before { user.should_receive(:subscribed_to_proposal_closure_notifications).and_return(true) }

      it 'emails user motion_closing_soon' do
        UserMailer.should_receive(:motion_closing_soon).with(user, motion)
        event.save
      end
    end
    context "user is not subscribed to proposal closure notifications" do
      before { user.should_receive(:subscribed_to_proposal_closure_notifications).and_return(false) }

      it 'does not email user motion_closing_soon' do
        UserMailer.should_not_receive(:motion_closing_soon)
        event.save
      end
    end
    it 'notifies group admins' do
      event.should_receive(:notify!).with(user)
      event.save
    end
  end
end
