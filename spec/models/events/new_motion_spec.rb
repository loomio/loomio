require 'spec_helper'

describe Events::NewMotion do
  let(:discussion){ mock_model(Discussion) }
  let(:motion){ mock_model(Motion, discussion: discussion, group: double(:group)) }

  describe "::publish!" do
    let(:event){ double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_motion',
                                          eventable: motion,
                                          discussion_id: motion.discussion.id)
      Events::NewMotion.publish!(motion)
    end

    it 'returns an event' do
      Events::NewMotion.publish!(motion).should == event
    end
  end

  context "after event has been published" do
    let(:user){ mock_model(User) }
    let(:event) { Events::NewMotion.new(kind: "new_motion",
                                        eventable: motion,
                                        discussion_id: motion.discussion.id) }
    before do
      motion.stub(:group_members_without_motion_author).and_return([user])
      user.stub(:email_notifications_for_group?).and_return(false)
      MotionMailer.stub_chain(:new_motion_created, :deliver)
    end


    context 'if user is subscribed to group notification emails' do
      before { user.should_receive(:email_notifications_for_group?).
                    with(motion.group).and_return(true) }

      it 'emails group_members_without_motion_author new_motion_created' do
        MotionMailer.should_receive(:new_motion_created).with(motion, user)
        event.save
      end
    end

    context 'if user is not subscribed to group notification emails' do
      before { user.should_receive(:email_notifications_for_group?).
                    with(motion.group).and_return(false) }

      it 'does not email new motion created' do
        MotionMailer.should_not_receive(:new_motion_created)
        event.save
      end
    end
  end
end
