require 'spec_helper'

describe Events::MotionEdited do
  let(:discussion) { mock_model(Discussion) }
  let(:motion) { mock_model(Motion, discussion: discussion) }
  let(:editor) { mock_model(User, email: 'bill@dave.com') }

  describe "::publish!" do
    let(:event) { stub(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'motion_edited',
                                          eventable: motion,
                                          user: editor,
                                          discussion_id: motion.discussion.id)
      Events::MotionEdited.publish!(motion, editor)
    end

    it 'returns an event' do
      Events::MotionEdited.publish!(motion, editor).should == event
    end
  end

  context "after event has been published" do
    let(:user) { mock_model(User, email: 'sharon@foo.com') }
    let(:event) { Events::MotionEdited.new(kind: "motion_edited",
                                           eventable: motion,
                                           user: editor,
                                           discussion_id: motion.discussion.id) }

    before do
      motion.stub(:editor).and_return(editor)
      Queries::Voters.stub(:users_that_voted_on).with(motion).and_return([user])
      MotionMailer.stub_chain(:motion_edited, :deliver)
    end

    it 'emails members who have voted' do
      MotionMailer.should_receive(:motion_edited).with(motion, user.email, editor)
      event.save
    end

    it 'notifies members who have voted' do
      event.should_receive(:notify!).with(user)
      event.save
    end

    it 'does not notify other the editor' do
      event.should_not_receive(:notify!).with(editor)
      event.save
    end
  end
end